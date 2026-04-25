#ifndef MODELDATAADAPTER_H
#define MODELDATAADAPTER_H

#include <QByteArray>
#include <QVariant>
#include <QHash>

/*
 *  ModelDataAdapter
 *  在ModelView中， 每一个item的自定义数据最理想的做法就是能定义一个结构体。
 *  由于Qt框架在Model映射到QML时， 是根据role的值，和roleName来映射的。
 *  例如role值为Qt::UserRole, role name为"name", role值为Qt::UserRole + 1, role name为"age"
 *  映射到QML的View中的每一个item的model中对应的属性 model.name和 model.age。
 *  每一个role的值， 还有根据role值获取值(data函数)，或者根据role值修改值(setData函数)
 *  都需要维护它对应的唯一role值、data函数、setData函数、名称信息。 ModelDataAdapter就是解决这个问题。
 *  通过良好的封装， 可以自动把读写操作，对应到任意结构体的任意字段。
 *  对每一个结构体成员， 调用一个addRole函数，就能自动维护处理好以上所有内容。
*/



template<typename T>
class ModelDataAdapter
{
public:
    ModelDataAdapter() {}

    template<typename T_StructParam>
    void addRole(T_StructParam T::*member_address, const QByteArray& role_name)
    {
        _roles_map[_next_role] = {
            role_name,
            [member_address](const T& s){
                return QVariant(s.*member_address);
            },
            [member_address](T* p_s, const QVariant& v){
                if(v.canConvert<T_StructParam>()){
                    auto new_value = v.value<T_StructParam>();
                    if(p_s->*member_address != new_value){
                        p_s->*member_address = new_value;
                        return true;
                    }else{
                        return false;
                    }
                }else{
                    return false;
                }
            }
        };
        _member_addr_info[_Param0ffSet(member_address)] = {_next_role, role_name};
        _next_role++;
    }


    template<typename T_StructParam>
    int roleId(T_StructParam T::*member_address)
    {
        auto iter = _member_addr_info.find(_Param0ffSet(member_address));
        if(iter == _member_addr_info.end()){
            return -1;
        }
        return iter.value().role_id;
    }

    template<typename T_StructParam>
    QByteArray roleName(T_StructParam T::*member_address)
    {
        auto iter = _member_addr_info.find(_Param0ffSet(member_address));
        if(iter == _member_addr_info.end()){
            return "";
        }
        return iter.value().role_name;
    }

    QHash<int, QByteArray> roleNames() const
    {
        QHash<int, QByteArray> role_names;
        for (auto iter = _roles_map.begin(); iter != _roles_map.end(); iter++) {
            role_names[iter.key()] = iter.value().role_name;
        }
        return role_names;
    }

    QVector<int> allRoles() const{
        QVector<int> all_roles;
        for (auto iter = _roles_map.begin(); iter != _roles_map.end(); iter++) {
            all_roles.push_back(iter.key());
        }
        return all_roles;
    }

    QVariant data(const T& s, int role) const
    {
        auto iter = _roles_map.find(role);
        if(iter == _roles_map.end()){
            return QVariant();
        }
        return iter.value().get_data_func(s);
    }

    // 值被修改返回true, 否则返回false
    bool setData(T* p_s, int role, const QVariant& value)
    {
        auto iter = _roles_map.find(role);
        if (iter == _roles_map.end()) {
            return false;
        }
        return iter.value().set_data_func(p_s, value);
    }

    int fetchRoleId() // 返回一个可用的role id， 并且它不会再使用。
    {
        return _next_role++;
    }

private:
    int _next_role = Qt::UserRole + 1; // 下一个角色值。初始化为Qt::UserRole

    // 结构体的某个字段的信息。
    struct RoleInfo
    {
        QByteArray role_name;
        std::function<QVariant(const T& s)> get_data_func;
        std::function<bool(T* p_s, const QVariant& v)> set_data_func;
    };
    QHash<int, RoleInfo> _roles_map; // 每一个role id映射该结构体字段的信息。

    struct MemberAddrInfo
    {
        int role_id;
         QByteArray role_name;
    };
    QHash<quint64, MemberAddrInfo> _member_addr_info;


    template<typename T_StructParam>
    uint64_t _Param0ffSet(T_StructParam T::* member_addr)
    {
         T* p_t = 0;
         auto offset = &(p_t->*member_addr);
         return reinterpret_cast<uint64_t>(offset);
    }

};

#endif // MODELDATAADAPTER_H
