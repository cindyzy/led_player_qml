#ifndef CPP_TREE_MODEL_H
#define CPP_TREE_MODEL_H

#include <QStandardItemModel>
#include <functional>
#include <QQmlEngine>
#include "ModelDataAdapter.h"

/*
 *  实现C++结构体的成员变量映射到QML中的ListView中的delegate(item显示实现)中的model对象中的属性值。
 *  Qt框架中，c++model是通过role id来区分不同的data。 该role id的role name会直接映射成ListView delegate model中相同名称的属性。
 *  通过role id去获取值、设置值等操作都是比较相似的，因此抽象出一个基本类，方便快速扩展。
*/


template<typename T>
class CppTreeModel: public QStandardItemModel
{
public:
    CppTreeModel(QObject *parent = nullptr): QStandardItemModel(parent){}

    /*
     *  CppTreeModel的目的
     *  1. 设置role name映射， 把任意自定义结构体的任意成员与某个属性名称绑定在一起。与QML层建立关联。
     *  2. c++层或者QML层建立数据绑定， 无论哪边作修改操作， 都能立即同步。例如c++后台数据更新，QML跟随着更新。
     *   QML层操作， 修改某些属性值， c++也会收到itemChanged通知？ 还是dataChanged?
     *  3. 如果后台的数据接口，总是返回所有数据的话， 效果最佳应该是， 先同步行数，然后同步所有的数据？QStandardItem
     *  内部应该有判断, 设置role值时，不相同才会触发dataChanged。以及itemChanged。待验证。实际上也可以通过key判断
     *  删除掉的节点， 这样操作效率和效果更佳。
     *  4. 如果后台数据， 根据每个节点的key来更新的话，只更新某个节点。树结构十分合适。
     *
    */

    class ModelItem: public QStandardItem
    {
    public:
        // 允许直接从结构体来读取当前值，这样效率更高。
        // 但是修改操作还是要经过封装的函数， 这样可以确保每个修改都触发dataChanged消息。
        const T& user_data;

        ModelItem():user_data(_private_user_data){}
        ModelItem(const T& s):_private_user_data(s), user_data(_private_user_data){}

        // 必须加上拷贝构造函数，否则user_data引用默认会引用拷贝源的值。
        ModelItem(const ModelItem& rhs):_private_user_data(rhs._private_user_data), user_data(_private_user_data){}
        ~ModelItem(){
            //qDebug() << "ModelItem destruct";
        }

        void copyUserData(const ModelItem& rhs)
        {
            _private_user_data = rhs.user_data;
        }

        virtual QVariant data(int role = Qt::UserRole + 1) const
        {
            CppTreeModel* p_model = dynamic_cast<CppTreeModel*>(model());
            if(p_model != nullptr){
                return p_model->data(this, role);
            }else{
                return QStandardItem::data(role);
            }
        }

        virtual void setData(const QVariant &value, int role = Qt::UserRole + 1)
        {
            CppTreeModel* p_model = dynamic_cast<CppTreeModel*>(model());
            if(p_model != nullptr){
                p_model->setData(this, value, role);
            }else{
                QStandardItem::setData(value, role);
            }
        }

        template<typename T_StructParam>
        void setMemberData(T_StructParam T::*member_address, const T_StructParam& value)
        {
            if(_private_user_data.*member_address == value){
                return; // 值没有变化
            }
            _private_user_data.*member_address = value;

            // model()是QStandardItem插入到一个model或者model里的节点时设置的。例如appendRow
            CppTreeModel* p_model = dynamic_cast<CppTreeModel*>(model());
            // 设置值的时候，item有可能还没加入到model, 此时无需触发memberDataChanged信号
            if(p_model != nullptr){
                p_model->memberDataChanged(this, member_address);
            }
        }

        template<typename T_StructParam>
        void getMemberData(T_StructParam T::*member_address, T_StructParam& value)
        {
            value = _private_user_data.*member_address;
        }
    private:
        T _private_user_data; // 真正保存数据的地方。

        friend class CppTreeModel; // CppTreeModel也会修改_private_user_data。
    };

    ModelItem* modelItem(int row, int col = 0, const QModelIndex& parent = QModelIndex()) const
    {
        if(parent.isValid()){
            QStandardItem* parent_item = itemFromIndex(parent);
            if(!parent_item){
                return nullptr;
            }
            return dynamic_cast<ModelItem*>(parent_item->child(row, col));
        }else{
            return dynamic_cast<ModelItem*>(item(row, col));
        }
    }

    ModelItem* modelItem(const QModelIndex& item_index) const
    {
        return dynamic_cast<ModelItem*>(itemFromIndex(item_index));
    }


    template<typename T_StructParam>
    void addItemModelAttribute(T_StructParam T::*member_address, const QString& role_name)
    {
        _adapter.addRole(member_address, role_name.toUtf8());
    }

    int fetchRoleId()
    {
        return _adapter.fetchRoleId();
    }

    virtual QHash<int, QByteArray> roleNames() const
    {
        return _adapter.roleNames();
    }

    QVector<int> allRoles() const
    {
        return _adapter.allRoles();
    }

    template<typename T_StructParam>
    int roleId(T_StructParam T::*member_address)
    {
        return _adapter.roleId(member_address);
    }

    template<typename T_StructParam>
    QByteArray roleName(T_StructParam T::*member_address)
    {
        return _adapter.roleName(member_address);
    }

    // 返回满足指定匹配函数的元素的索引。
    QList<QModelIndex> search(
        std::function<bool(const T& s)> match_func,
        const QModelIndex& parent_index = QModelIndex(), // 需要搜索的父节点的index
        bool recursive = false // 是否递归查找子节点， 如果false只找一层
    )
    {
        QList<QModelIndex> ret_indexes;
        _InternalSearch(&ret_indexes, parent_index.isValid() ? itemFromIndex(parent_index) : invisibleRootItem(), match_func, recursive);
        return ret_indexes;
    }

protected:
    ModelDataAdapter<T> _adapter;

private:
    static void _InternalSearch(
        QList<QModelIndex>* p_ret_indexes,
        const QStandardItem* parent_item,
        const std::function<bool(const T& s)>& match_func,
        bool recursive
        )
    {
        if(parent_item == nullptr){
            return;
        }

        int row_count = parent_item->rowCount();
        for(int i = 0; i < row_count; i++){
            ModelItem* p_item = dynamic_cast<ModelItem*>(parent_item->child(i, 0));
            if(p_item == nullptr){
                continue;
            }
            if(match_func(p_item->_private_user_data)){
                p_ret_indexes->push_back(p_item->index());
            }
            if(recursive){ // 继续递归
                _InternalSearch(p_ret_indexes, p_item, match_func, recursive);
            }
        }
    }

private:
    QVariant data(const ModelItem* p_item, int role) const
    {
        return _adapter.data(p_item->_private_user_data, role);
    }

    // 如果值被修改返回true, 值不变返回false
    void setData(ModelItem* p_item, const QVariant &value, int role)
    {
        if (_adapter.setData(&p_item->_private_user_data, role, value)) {
            emit dataChanged(p_item->index(), p_item->index(), { role }); // 值变化才会发出这个信号。
        }
    }


    template<typename T_StructParam>
    void memberDataChanged(ModelItem* p_item, T_StructParam T::*member_address)
    {
        emit dataChanged(p_item->index(), p_item->index(), {_adapter.roleId(member_address)}); // 值变化才会发出这个信号。
        // dataChanged信号会自动触发itemChanged信号。
    }

    friend class ModelItem;
};




// 在构造时， 自动执行某些逻辑
class ConstructDo
{
public:
    ConstructDo(std::function<void()> do_func)
    {
        do_func();
    }
};

// c++属性自动映射成QML属性的基础实现。
template<typename T_Model>
class QmlAttrDefine: public QObject
{
public:
    QmlAttrDefine(QObject* parent = nullptr): QObject(parent){}

    using SetAttrFunc = std::function<void(T_Model* p_model)>;

    // 添加属性设置函数。
    void addAttributeSetupFunc(SetAttrFunc func)
    {
        _add_attr_funcs.push_back(func);
    }

    // 对指定的model，设置所有添加的属性。
    void setupAttributes(T_Model* p_model)
    {
        for(const auto& add_attr_func: _add_attr_funcs){
            add_attr_func(p_model);
        }
    }

private:
    std::list<SetAttrFunc> _add_attr_funcs;
};


// 方便自定义的结构体的名称结构体定义各个成员属性的名称。
// decltype(struct_name::attr_name) attr_name##_dummy; 为了利用编译器确保没有填错属性名称。
// ConstructDo _add_##attr_name##_attr = ConstructDo([this]()是为了在类构造的时候，自动执行某些逻辑
// 执行的逻辑就是调用基类的addAttributeSetupFunc函数，添加一个当前属性的向CppTreeModel添加当前属性的匿名函数。
// Q_PROPERTY中必须声明CONSTANT， 否则引用该属性的时候，会提示QQmlExpression: Expression  depends on non-NOTIFYable properties警告
#define Model_Attr(struct_name, attr_name)\
    decltype(struct_name::attr_name) attr_name##_dummy; \
    ConstructDo _add_##attr_name##_attr = ConstructDo([this](){\
        addAttributeSetupFunc([](CppTreeModel<struct_name>* p_model){\
        p_model->addItemModelAttribute(&struct_name::attr_name, #attr_name);\
        });\
    });\
    QString attr_name = #attr_name;\
    Q_PROPERTY(QString attr_name MEMBER attr_name CONSTANT)



// 实现类必须定义CppTreeModel<struct_name>::ModelItem* _p_item;
// 由于Q_PROPERTY内部不能使用decltype来表达类型，(猜测moc编译器不认)
// 因此所有的属性都定义成QVariant类型。
#define Model_Imp(struct_name, attr_name)\
const decltype(struct_name::attr_name)& attr_name() const{\
        return _p_item->user_data.attr_name;\
}\
    QVariant attr_name##Get() const{\
        return _p_item->user_data.attr_name;\
}\
    void attr_name##Set(const QVariant& value){\
        _p_item->setMemberData(&struct_name::attr_name, value.value<decltype(struct_name::attr_name)>());\
}\
    Q_PROPERTY(QVariant attr_name READ attr_name##Get WRITE attr_name##Set)


// 提供C++实现QML单例的通用实现。 只需要指定类型，即可自动实现。
using QmlSignletonCallback = QObject *(*)(QQmlEngine *, QJSEngine *);

template<typename T>
static QmlSignletonCallback CommonSingletonCallbackFunc()
{
    return [](QQmlEngine *qmlEngine, QJSEngine* js_engine)->QObject*{
        // QML中只有一个UI线程会调用， 因此不用加锁。
        static T* s_instance = new T(qmlEngine);
        Q_UNUSED(js_engine);
        return s_instance;
    };
}



#endif // CPP_TREE_MODEL_H
