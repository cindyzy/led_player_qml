#include "include/treeviewmodel.h"
#include <QDebug>
#include <thread>



TreeData::TreeData(QJsonObject* p_json_obj): _p_json_obj(p_json_obj), _any_data_changed(false)
{

}

TreeData::~TreeData()
{

}

TreeData::TreeData(const TreeData& rhs): _p_json_obj(rhs._p_json_obj), _any_data_changed(false)
{

}


QVariant TreeData::getKey(const QString& key) const
{
    return _p_json_obj->value(key).toVariant();
}

int TreeData::depth() const
{
	return _p_json_obj->value(cDepthKey).toInt();
}

bool TreeData::expand() const
{
	return _p_json_obj->value(cExpendKey).toBool();
}

bool TreeData::childrenExpand() const
{
	return _p_json_obj->value(cChildrenExpendKey).toBool();
}

bool TreeData::hasChildren() const
{
	return _p_json_obj->value(cHasChildendKey).toBool();
}


QJsonObject TreeData::userDataJsonObject(int index) const
{
    return FilteredJsonObject(*_p_json_obj, cFilterKeyList, index);
}

QJsonObject TreeData::FilteredJsonObject(const QJsonObject& origin, const QStringList& filter_list, int index)
{
	auto ret_obj = QJsonObject(origin);
	for (auto& key : filter_list) {
		ret_obj.remove(key);
	}
    ret_obj["index"] = index;
	return ret_obj;
}


bool TreeData::anyDataChanged() const // 是否有数据发生变化
{
    return _any_data_changed;
}

void TreeData::setKey(const QString& key, const QVariant& value)
{
    _any_data_changed |= _SetKey(_p_json_obj, key, value);
    //(*_p_json_obj)[key] = QJsonValue::fromVariant(value);
}

void TreeData::setDepth(int new_depth)
{
    _any_data_changed |= _SetKey(_p_json_obj, cDepthKey, new_depth);
}

void TreeData::setExpand(bool is_expand)
{
    _any_data_changed |= _SetKey(_p_json_obj, cExpendKey, is_expand);
    //(*_p_json_obj)[cExpendKey] = is_expand;
}

void TreeData::setChildrenExpand(bool children_expand)
{
    _any_data_changed |= _SetKey(_p_json_obj, cChildrenExpendKey, children_expand);
    //(*_p_json_obj)[cChildrenExpendKey] = children_expand;
}

void TreeData::setHasChildren(bool has_children)
{
    _any_data_changed |= _SetKey(_p_json_obj, cHasChildendKey, has_children);
    //(*_p_json_obj)[cHasChildendKey] = has_children;
}

bool TreeData::_SetKey(QJsonObject* p_json_obj, const QString& key, const QVariant& value)
{
    if(!p_json_obj->contains(key) || (*p_json_obj)[key].toVariant() != value){
        (*p_json_obj)[key] = QJsonValue::fromVariant(value);
        return true;
    }else{
        return false;
    }
}




TreeModelInternal::TreeModelInternal(QAbstractListModel* list_model, QList<QJsonObject>* p_node_list, QObject* parent):
    QObject(parent), _list_model(list_model), _p_node_list(p_node_list)
{

}

TreeModelInternal::~TreeModelInternal()
{

}

int TreeModelInternal::count() const
{
	return _p_node_list->size();
}

void TreeModelInternal::clear(
	std::function<void(int first, int last)> begin_remove_rows_func,
	std::function<void()> end_remove_rows_func
)
{
    remove(-1, begin_remove_rows_func, end_remove_rows_func);
}

int TreeModelInternal::addNode(
    int parent_index,
    const QJsonObject& node,
    std::function<void(int first, int last)> begin_insert_rows_func,
    std::function<void()> end_insert_rows_func
    )
{
    if (parent_index < 0 || parent_index >= _p_node_list->size()) {
        // 加入到顶层菜单
        if(begin_insert_rows_func){
            begin_insert_rows_func(_p_node_list->size(), _p_node_list->size());
        }
        _p_node_list->append(_CreateTreeNode(node, 0));
        if(end_insert_rows_func){
            end_insert_rows_func();
        }
        return (_p_node_list->count() - 1);
    }else{
        auto parent_node = _Node(_p_node_list, parent_index);
        auto child_infos = _ChildrenInfos(_p_node_list, parent_index);
        int inserted_index = child_infos.empty() ? (parent_index + 1) : (child_infos.back().index + child_infos.back().cost_count);
        if(begin_insert_rows_func){
            //qDebug() << "begin insert rows index = " << inserted_index;
            begin_insert_rows_func(inserted_index, inserted_index);
        }
        _p_node_list->insert(inserted_index, _CreateTreeNode(node, parent_node.depth() + 1));
        if(end_insert_rows_func){
            //qDebug() << "end insert rows index = " << inserted_index;
            end_insert_rows_func();
        }
        return inserted_index;
    }
}

void TreeModelInternal::remove( // 删除指定节点，及其children。
    int index,
    std::function<void(int, int)> begin_remove_rows_func,
    std::function<void()> end_remove_rows_func
)
{
	if (index == -1) {
        if (_p_node_list->size() > 0) {
            //qDebug() << "begin remove rows 0 - " <<  _p_node_list->size() - 1;
            begin_remove_rows_func(0, _p_node_list->size() - 1);
			_p_node_list->clear();
            //qDebug() << "end remove rows";
			end_remove_rows_func();
        }
	}
	else {
		int total_node_count = _TotalNodeCount(_p_node_list, index);
        //qDebug() << "begin remove rows "<< index << " - " <<  index + total_node_count - 1;
        begin_remove_rows_func(index, index + total_node_count - 1);
		for (int i = 0; i < total_node_count; i++) {
			_p_node_list->removeAt(index);
		}
        //qDebug() << "end remove rows";
        end_remove_rows_func();
	}
}

void TreeModelInternal::removeRows(
    int index, 
    int start_row, 
    int row_count,
	std::function<void(int, int)> begin_remove_rows_func,
	std::function<void()> end_remove_rows_func
)
{
    QList<TreeModelInternal::NodeInfo> child_infos = _ChildrenInfos(_p_node_list, index);
    if (start_row >= 0 && row_count > 0 && start_row + row_count <= child_infos.size()) {
        int remove_start_index = child_infos[start_row].index;
        int remove_end_index = child_infos[start_row + row_count - 1].index + child_infos[start_row + row_count - 1].cost_count - 1;
        int total_remove_count = remove_end_index - remove_start_index + 1;
        //qDebug() << "begin remove rows "<< remove_start_index << " - " <<  remove_end_index;
        begin_remove_rows_func(remove_start_index, remove_end_index);
        for (int i = 0; i < total_remove_count; i++) {
            _p_node_list->removeAt(remove_start_index);
        }
        //qDebug() << "end remove rows";
        end_remove_rows_func();
    }
}


const TreeData TreeModelInternal::nodeData(int index) const
{
	//return _Node(const_cast<QList<QJsonObject>*>(p_node_list), index);
    return _Node(_p_node_list, index);
}

TreeData TreeModelInternal::nodeData(int index)
{
    return _Node(_p_node_list, index);
}

void TreeModelInternal::dataUpdated(int index)
{
    emit dataChanged(index, index, { Qt::DisplayRole, Qt::EditRole });
}

TreeData TreeModelInternal::_Node(QList<QJsonObject>* p_node_list, int index)
{
    return TreeData(&((*p_node_list)[index]));
}

QList<TreeModelInternal::NodeInfo> TreeModelInternal::_ChildrenInfos(QList<QJsonObject>* p_node_list, int parent_index)
{
    QList<TreeModelInternal::NodeInfo> ret_infos;
    int parent_depth;
    if(parent_index == -1){
        parent_depth = -1;

    }else{
        auto parent_node = _Node(p_node_list, parent_index);
        parent_depth = parent_node.depth();
    }

    for (int i = parent_index + 1; i < p_node_list->size(); i++) {
        auto child_node = _Node(p_node_list, i);
        if (child_node.depth() <= parent_depth) { // 遇到parent节点的同级节点或者parent的parent节点。
            break;
        }
        else if (child_node.depth() == parent_depth + 1) { // 子节点
            ret_infos.push_back({i, 1});
        }
        else {
            // 子节点的子节点并不作为children. 但是计算它占用的列表节点数
            if(!ret_infos.empty()){
                ret_infos.back().cost_count++;
            }else{
                assert(0); // 异常
            }
        }
    }
    return ret_infos;
}


int TreeModelInternal::_ChildrenCount(QList<QJsonObject>* p_node_list, int parent_index)
{
    return _ChildrenInfos(p_node_list, parent_index).size();
}

int TreeModelInternal::_TotalNodeCount(QList<QJsonObject>* p_node_list, int index)
{
    auto child_infos = _ChildrenInfos(p_node_list, index);
    if (child_infos.empty()) {
        return 1;
    }
    else {
        return (child_infos.back().index + child_infos.back().cost_count - index);
    }
}

int TreeModelInternal::_ParentIndex(QList<QJsonObject>* p_node_list, int node_index)
{
	auto cur_node = _Node(p_node_list, node_index);
	int cur_node_depth = cur_node.depth();
	for (int i = node_index - 1; i >= 0; i--) {
		auto pre_node = _Node(p_node_list, i);
		if (pre_node.depth() == cur_node_depth - 1) { // 比当前节点深度小1的就是父节点
			return  i;
		}
	}
	return -1;
}

void TreeModelInternal::expand(int index)
{
    auto child_infos = _ChildrenInfos(_p_node_list, index);
    for(const auto& info: child_infos){
        auto child_node = _Node(_p_node_list, info.index);
        child_node.setExpand(true);
    }
	auto parent_node = _Node(_p_node_list, index);
	parent_node.setChildrenExpand(true);
    if(child_infos.empty()){
        emit dataChanged(index, index, { Qt::DisplayRole, Qt::EditRole });
    }else{
        emit dataChanged(index, child_infos.back().index + child_infos.back().cost_count - 1, { Qt::DisplayRole, Qt::EditRole });
    }
}


void TreeModelInternal::expandAll()
{
	for (int i = 0; i < _p_node_list->size(); i++) {
		auto cur_node = _Node(_p_node_list, i);
		if (cur_node.hasChildren()) {
			cur_node.setChildrenExpand(true);
		}
		cur_node.setExpand(true);
	}
    if(_p_node_list->size() > 0){
        emit dataChanged(0, _p_node_list->size() - 1, { Qt::DisplayRole, Qt::EditRole });
    }
}

void TreeModelInternal::collapse(int index)
{
    auto node = _Node(_p_node_list, index);
	node.setChildrenExpand(false);
    auto child_infos = _ChildrenInfos(_p_node_list, index);
    if(!child_infos.empty()){
        for(int i = child_infos.front().index; i < child_infos.back().index + child_infos.back().cost_count; i++){
            auto child_node = _Node(_p_node_list, i);
            child_node.setExpand(false);
            child_node.setChildrenExpand(false);
        }
    }
    if(child_infos.empty()){
        emit dataChanged(index, index, { Qt::DisplayRole, Qt::EditRole });
    }else{
        emit dataChanged(index, child_infos.back().index + child_infos.back().cost_count - 1, { Qt::DisplayRole, Qt::EditRole });
    }
}

void TreeModelInternal::collapseAll()
{
	for (int i = 0; i < _p_node_list->size(); i++) {
		auto cur_node = _Node(_p_node_list, i);
		if (cur_node.hasChildren()) {
			cur_node.setChildrenExpand(false);
		}
		if (cur_node.depth() > 0) { // 第1层不折叠
			cur_node.setExpand(true);
		}
	}
    if(_p_node_list->size() > 0){
        emit dataChanged(0, _p_node_list->size() - 1, { Qt::DisplayRole, Qt::EditRole });
    }
}

QList<int> TreeModelInternal::search(const QString& key, const QString& value) const
{
	if (key.isEmpty() || value.isEmpty()) {
		return {};
	}

	QList<int> ret_indexes;
	for (int i = 0; i < _p_node_list->size(); i++) {
		auto node = _Node(_p_node_list, i);
		if (node.getKey(key).toString() == value) {
			ret_indexes.push_back(i);
		}
	}
	return ret_indexes;
}


QJsonObject TreeModelInternal::_CreateTreeNode(const QJsonObject& user_data, int depth)
{
	QJsonObject node_obj(user_data);
	TreeData tree_data(&node_obj);
	tree_data.setDepth(depth);
	tree_data.setExpand(true); // 默认expand为true。
	tree_data.setChildrenExpand(false);
	tree_data.setHasChildren(false);
	return node_obj;
}

int TreeModelInternal::parentIndex(int node_index) const
{
	return _ParentIndex(_p_node_list, node_index);
}

// 返回下一个兄弟节点的index(节点不存在也照样放回，插入节点时需要), node_index必须合法
int TreeModelInternal::nextSiblingIndex(int node_index) const
{
	assert(node_index >= 0 && node_index < _p_node_list->size());

	TreeData node_data(&((*_p_node_list)[node_index]));
	int node_depth = node_data.depth();

	for (int i = node_index + 1; i < _p_node_list->size(); i++) {
		TreeData iter_node(&((*_p_node_list)[i]));
		if (iter_node.depth() <= node_depth) {
			return i;
		}
	}
	return _p_node_list->size();
}

// 确保传入的都是有效值。
int TreeModelInternal::childrenCount(int node_index) const
{
	return _ChildrenCount(_p_node_list, node_index);
}

QList<TreeModelInternal::NodeInfo> TreeModelInternal::childrenInfos(int parent_index) const
{
    return _ChildrenInfos(_p_node_list, parent_index);
}










TreeViewModel::TreeViewModel(QObject *parent): _tree_model(this, &m_nodeList), _abstract_item_model(this)
{
    // 子类使用TreeModelInternal来更新数据， 最后在这里处理其信号， 并发出Qt model标准的dataChanged消息。
    bool conn_ret = connect(&_tree_model, &TreeModelInternal::dataChanged, this, &TreeViewModel::listDataChanged);
    assert(conn_ret == true);
}

TreeViewModel::~TreeViewModel(){


}

void TreeViewModel::clear()
{
    //beginResetModel();
	_tree_model.clear(
        [this](int first, int last) {_abstract_item_model->beginRemoveRows(QModelIndex(), first, last); },
        [this]() {_abstract_item_model->endRemoveRows(); }
    );
    //endResetModel();
}

int TreeViewModel::addNode(int parent_index, const QJsonObject& json)
{
    int added_index = _tree_model.addNode(
        parent_index,
        json,
        [this](int first, int last){_abstract_item_model->beginInsertRows(QModelIndex(), first, last);},
        [this](){_abstract_item_model->endInsertRows();}
    );
    _tree_model.dataUpdated(added_index);
    if (parent_index != -1) {
		auto parent_node = _tree_model.nodeData(parent_index);
		parent_node.setHasChildren(true);
		if (parent_node.anyDataChanged()) {
			_tree_model.dataUpdated(parent_index);
		}
    }
//	_abstract_item_model->beginInsertRows(QModelIndex(), _tree_model.count(), _tree_model.count());
//	int added_index = _tree_model.addNode(index, json);
//	_abstract_item_model->endInsertRows();

	// 如果加入的不是最顶层， expand?
    //expandTo(added_index);

	return added_index;
}
int TreeViewModel::addNode(const QModelIndex& index, const QJsonObject& json)
{
    return addNode(index.row(), json);
}

QList<int> TreeViewModel::search(const QString& key, const QString& value) const
{
    return _tree_model.search(key, value);
}

void TreeViewModel::expand(int index)
{
    if (index < 0 || index >= _tree_model.count()) {
        return;
    }

    _tree_model.expand(index);

}
void TreeViewModel::expand(const QModelIndex& index)
{
    if (index.row() < 0 || index.row() >= _tree_model.count()) {
        return;
    }

	_tree_model.expand(index.row());
}

void TreeViewModel::collapse(int index)
{
	if (index < 0 || index >= _tree_model.count()) {
		return;
	}

	_tree_model.collapse(index);
}
void TreeViewModel::collapse(const QModelIndex& index)
{
	if (index.row() < 0 || index.row() >= _tree_model.count()) {
		return;
	}
	_tree_model.collapse(index.row());

    collapse(index.row());
}

/*
*   上层才知道自定义的用户数据。 所以应该提供接口，上层去遍历数据，找到想要的
*   然后再对其展开。
*/
void TreeViewModel::expandTo(int index)
{
    if (index < 0 || index >= _tree_model.count()) {
        return;
    }
    
    int parent_index = _tree_model.parentIndex(index);
    while (parent_index != -1) {
		_tree_model.expand(parent_index);
        parent_index = _tree_model.parentIndex(parent_index);
    }
}

void TreeViewModel::expandTo(QString deviceCode)
{
    const QList<QJsonObject>& nodelist=nodeList();
    for(int intNum=0; intNum<nodelist.count(); intNum++){
        if(nodelist[intNum].value("deviceCode").toString()==deviceCode)
        {
            expandTo(intNum);
            break;
        }
    }
}
void TreeViewModel::expandTo(const QModelIndex& index)
{
    //qDebug()<<"TreeViewModel::expandTo  QModelIndex--"<<index;
    expandTo(index.row());
}

void TreeViewModel::expandAll()
{
	_tree_model.expandAll();
}

void TreeViewModel::collapseAll()
{
	_tree_model.collapseAll();
}

void TreeViewModel::listDataChanged(int beginIndex, int endIndex, const QVector<int> &roles)
{
    auto thread_id = std::this_thread::get_id();
    //qDebug() << "thread_id= " << *((unsigned int*)&thread_id) <<  "tree data changed beginIndex=" << beginIndex << " end_index=" << endIndex << " roles size=" << roles.size();
    emit dataChanged(Super::index(beginIndex), Super::index(endIndex), roles);
}
