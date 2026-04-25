#ifndef TREEVIEWMODEL_H
#define TREEVIEWMODEL_H

#include <functional>
#include <QJsonArray>
#include <QJsonObject>
#include <QString>
#include <QAbstractItemModel>
#include "TreeViewListModel.h"
#include <QObject>
static const QString cDepthKey = QStringLiteral("TModel_depth");

// 标识该节点是否应该被显示，如果为false,则height=0, 这个属性实际上是visible。
static const QString cExpendKey = QStringLiteral("TModel_expend");

// 记录子节点有没有被展开，实际上与子节点的cExpandKey状态同步。控制展开标识小三角形的上下方向
static const QString cChildrenExpendKey = QStringLiteral("TModel_childrenExpend");
static const QString cHasChildendKey = QStringLiteral("TModel_hasChildren");
static const QString cParentKey = QStringLiteral("TModel_parent");
static const QString cChildrenKey = QStringLiteral("TModel_children");
static const QString cRecursionKey = QStringLiteral("subType");
static const QStringList cFilterKeyList = { cDepthKey, cExpendKey, cChildrenExpendKey, cHasChildendKey, cParentKey, cChildrenKey };


class TreeModelInternal;

class TreeData
{
public:
    ~TreeData();

    QVariant getKey(const QString& key) const; // 用户自定义的key 、value.
	int depth() const;
	bool expand() const;
	bool childrenExpand() const;
	bool hasChildren() const;
    QJsonObject userDataJsonObject(int index) const; // 返回用户数据的json对象， 并增加指定的index字段
    static QJsonObject FilteredJsonObject(const QJsonObject& origin, const QStringList& filter_list, int index);

    bool anyDataChanged() const; // 是否有数据发生变化？

    // 默认自动触发dataChanged更加简单清晰，然后再提供接口，可以禁用更新，然后主动一次更新多个提升效率。
    void setKey(const QString& key, const QVariant& value);
    void setDepth(int new_depth);
    void setExpand(bool is_expand);
    void setChildrenExpand(bool children_expand);
	void setHasChildren(bool has_children);
    
private:
    QJsonObject* _p_json_obj;
    bool _any_data_changed;

    // return true if the value of the key changed.
    static bool _SetKey(QJsonObject* p_json_obj, const QString& key, const QVariant& value);

private:
    TreeData(QJsonObject* p_json_obj);
    TreeData(const TreeData& rhs);
	
	
    friend class TreeModelInternal; // 只能由TreeModelInternal构造， 外部无法构造或者拷贝，改变const属性。限制const场景只能使用readonly函数。
};


/*
*   树应该提供的接口。 目前是用List去实现了一棵树
*   未来有可能会用树代替， 但是接口保持这一套不变。
*/
class TreeModelInternal: public QObject
{
    Q_OBJECT
public:
    TreeModelInternal(QAbstractListModel* list_model, QList<QJsonObject>* p_node_list, QObject* parent = nullptr);
    ~TreeModelInternal();

    int count() const;
	void clear(
        std::function<void(int first, int last)> begin_remove_rows_func,
		std::function<void()> end_remove_rows_func
    );
    // 把新节点加入到指定parent节点的末尾， 并返回该节点的index。parent_index==-1表示加入到顶层
    int addNode(
        int parent_index,
        const QJsonObject& node,
        std::function<void(int first, int last)> begin_insert_rows_func,
        std::function<void()> end_insert_rows_func
    );

    void remove( // 删除指定节点，及其children。
        int index,
		std::function<void(int first, int last)> begin_remove_rows_func,
		std::function<void()> end_remove_rows_func
    ); 
    void removeRows(
        int index,
        int start_row,
        int row_count,
        std::function<void(int, int)> begin_remove_rows_func,
        std::function<void()> end_remove_rows_func
    );
    
    // 未来改进为返回引用。List保存的不再是json object, 而是自定义结构。
    const TreeData nodeData(int index) const;
    TreeData nodeData(int index);
    void dataUpdated(int index); // 通知TreeModelInternal触发数据更新消息

    
    void expand(int index);
    void expandAll();
    void collapse(int index);
	void collapseAll();

    QList<int> search(const QString& key, const QString& value)  const;


    QJsonObject _CreateTreeNode(const QJsonObject& user_data, int depth);

    int parentIndex(int node_index) const;
    // 返回下一个兄弟节点的index(节点不存在也照样放回，插入节点时需要), node_index必须合法
    int nextSiblingIndex(int node_index)  const;
    // 确保传入的都是有效值。
    int childrenCount(int node_index)  const;

    struct NodeInfo
    {
        int index;
        int cost_count; // 该节点以及它的子节点，一共占用多少个node。
    };
    QList<NodeInfo> childrenInfos(int parent_index) const;


private:
    QAbstractListModel* _list_model;
    QList<QJsonObject>* _p_node_list;


    static TreeData _Node(QList<QJsonObject>* p_node_list, int index);
    static QList<NodeInfo> _ChildrenInfos(QList<QJsonObject>* p_node_list, int parent_index);
    static int _ChildrenCount(QList<QJsonObject>* p_node_list, int parent_index);
    // 返回某个节点以及它的所有子节点的总数
    static int _TotalNodeCount(QList<QJsonObject>* p_node_list, int index);
    static int _ParentIndex(QList<QJsonObject>* p_node_list, int node_index);


public slots:

signals:
    // item发生变化
    void dataChanged(int beginIndex, int endIndex, const QVector<int> &roles = QVector<int>());
};


/*
 *  两个问题
 *  1. 树在展开、收缩时， 树的位置会变。
 *  2. 当某个节点被收缩时， 它有一个子节点处于展开状态，  该子节点并不会隐藏。
*/
class TreeViewModel:public TreeViewListModel<QJsonObject>{
    Q_OBJECT
public:
    TreeViewModel(QObject *parent = nullptr);
    ~TreeViewModel();
    //声明父类
//    using Super = TreeViewListModel<QJsonObject>;
    Q_INVOKABLE void clear();

    /*
     *  从前所有的数据由QML层来管理， setNodeValue也就是setData实际上应该由c++来处理。
     *  实际上是display role一个地方， 管理着多个属性。因此又额外引入了setNodeValue和getNodeValue来实现
     *  实际上，可以使用通用接口data以及setData来实现。
    */

    /*
    //设置指定节点的数值
    Q_INVOKABLE void setNodeValue(int index, const QString &key, const QVariant &value);
    //获取置顶节点的数值
    Q_INVOKABLE QVariant getNodeValue(int index, const QString& key) ;
*/
    
    //在index添加子节点。刷新父级，返回新项index
    Q_INVOKABLE int addNode(int index, const QJsonObject& json);
    Q_INVOKABLE int addNode(const QModelIndex& index, const QJsonObject& json);
    /*
    //获取节点深度
    Q_INVOKABLE int getDepth(int index) ;
    //删除。递归删除所有子级,刷新父级
    Q_INVOKABLE void remove(int index);
    Q_INVOKABLE void remove(const QModelIndex& index);
    */

    Q_INVOKABLE QList<int> search(const QString& key, const QString& value) const;
    //展开子级。只展开一级,不递归
    Q_INVOKABLE void expand(int index);
    Q_INVOKABLE void expand(const QModelIndex& index);
    //折叠子级。递归全部子级。
    Q_INVOKABLE void collapse(int index);
    Q_INVOKABLE void collapse(const QModelIndex& index);
    //展开到指定项。递归
    Q_INVOKABLE void expandTo(int index);
    Q_INVOKABLE void expandTo(QString deviceCode);
    Q_INVOKABLE void expandTo(const QModelIndex& index);
    //展开全部
    Q_INVOKABLE void expandAll();
    //折叠全部
    Q_INVOKABLE void collapseAll();

protected:
    TreeModelInternal _tree_model;
    TreeViewModel* _abstract_item_model; // QAbstractItemModel
private:
    
    

public slots:
    void listDataChanged(int beginIndex, int endIndex, const QVector<int> &roles = QVector<int>());
signals:

};

#endif // TREEVIEWMODEL_H
