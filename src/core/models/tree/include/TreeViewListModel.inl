#include "TreeViewListModel.h"
template <typename T>
TreeViewListModel<T>::TreeViewListModel(QObject* parent)
    : Super(parent)
{
}

template <typename T>
TreeViewListModel<T>::TreeViewListModel(const QList<T>& nodeList, QObject* parent)
    : Super(parent)
    , m_nodeList(nodeList)
{
}
template <typename T>
Qt::ItemFlags TreeViewListModel<T>::flags(const QModelIndex& index) const
{
    if (!index.isValid())
        return Super::flags(index) | Qt::ItemIsDropEnabled;

    return Super::flags(index) | Qt::ItemIsEditable | Qt::ItemIsDragEnabled | Qt::ItemIsDropEnabled;
}

template <typename T>
void TreeViewListModel<T>::setNodeList(const QList<T>& nodeList)
{
    beginResetModel();
    m_nodeList = nodeList;
    endResetModel();
}

template <typename T>
int TreeViewListModel<T>::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid())
        return 0;
    return m_nodeList.count();
}
template <typename T>
QVariant TreeViewListModel<T>::data(const QModelIndex& index, int role) const
{
    if (index.row() < 0 || index.row() >= m_nodeList.size())
        return {};

    if (role == Qt::DisplayRole || role == Qt::EditRole)
        return m_nodeList.at(index.row());

    return {};
}
template <typename T>
bool TreeViewListModel<T>::setData(const QModelIndex& index, const QVariant& value, int role)
{
    if (index.row() >= 0 && index.row() < m_nodeList.size() && (role == Qt::EditRole || role == Qt::DisplayRole)) {
        auto realValue = value.value<T>();
        if (m_nodeList.at(index.row()) == realValue)
            return true;
        m_nodeList.replace(index.row(), realValue);
        emit dataChanged(index, index, { Qt::DisplayRole, Qt::EditRole });
        return true;
    }
    return false;
}


template <typename T>
bool TreeViewListModel<T>::insertRows(int row, int count, const QModelIndex& parent)
{
    if (count < 1 || row < 0 || row > rowCount(parent)) {
        return false;
    }
    beginInsertRows(QModelIndex(), row, row + count - 1);
    for (int i = 0; i < count; ++i) {
        m_nodeList.insert(row, T {});
    }
    endInsertRows();
    return true;
}

template <typename T>
bool TreeViewListModel<T>::removeRows(int row, int count, const QModelIndex& parent)
{
    if (count <= 0 || row < 0 || (row + count) > rowCount(parent)) {
        return false;
    }
    beginRemoveRows(QModelIndex(), row, row + count - 1);
    for (int i = 0; i < count; ++i) {
        m_nodeList.insert(row, T {}); // remove还insert？ 应该是BUG，待跟进
    }
    endRemoveRows();
    return true;
}

template <typename T>
Qt::DropActions TreeViewListModel<T>::supportedDropActions() const
{
    return Super::supportedDropActions() | Qt::MoveAction;
}
 // namespace TaoCommon


