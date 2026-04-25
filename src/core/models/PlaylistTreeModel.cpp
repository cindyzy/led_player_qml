#include "PlaylistTreeModel.h"
#include <QDebug>
#include <QStack>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

PlaylistTreeModel::PlaylistTreeModel(QObject* parent)
    : TreeViewModel(parent)
    , m_programCounter(1)
    , m_windowCounter(1)
{
}

PlaylistTreeModel::~PlaylistTreeModel()
{
}

void PlaylistTreeModel::initializeModel()
{
    clear();
    m_programCounter = 1; // 重置计数器
    m_windowCounter = 1;  // 重置窗口计数器
    m_programNames.clear(); // 清空已使用的节目名
    m_windowNames.clear();  // 清空窗口名映射
    m_materialNames.clear(); // 清空素材名映射
}

void PlaylistTreeModel::createProgramNode(int parentIndex, const QString& programName, int programIndex)
{
    QString finalProgramName = programName;

    // 如果节目名为空，则生成默认节目名
    if (programName.isEmpty()) {
        // 生成默认节目名
        do {
            finalProgramName = QString("节目%1").arg(m_programCounter);
            m_programCounter++;
        } while (m_programNames.contains(finalProgramName));
    } else {
        // 检查节目名是否已存在
        if (m_programNames.contains(programName)) {
            // 如果已存在，添加序号后缀
            int counter = 1;
            QString newName = programName;
            do {
                newName = QString("%1(%2)").arg(programName).arg(counter);
                counter++;
            } while (m_programNames.contains(newName));
            finalProgramName = newName;
        }
    }

    // 添加到已使用节目名列表
    m_programNames.insert(finalProgramName);

    int newProgramIndex = addNode(parentIndex, QJsonObject({
                                                   {"name", finalProgramName},
                                                   {"icon", "📁"},
                                                   {"duration", "0.00s"},  // 初始为0
                                                   {"type", "program"}
                                               }));

    // 初始化这个节目下的窗口名集合
    m_windowNames[newProgramIndex] = QSet<QString>();

    qDebug() << "创建节目节点:" << finalProgramName << "索引:" << newProgramIndex;
}

void PlaylistTreeModel::createWindowNode(int parentIndex, const QString& windowName, int windowIndex)
{
    QString finalWindowName = windowName;

    // 获取父节目节点下的窗口名集合
    if (m_windowNames.contains(parentIndex)) {
        QSet<QString>& windowSet = m_windowNames[parentIndex];

        // 如果窗口名为空，则生成默认窗口名
        if (windowName.isEmpty()) {
            // 生成默认窗口名
            int counter = 1;
            do {
                finalWindowName = QString("窗口%1").arg(counter);
                counter++;
            } while (windowSet.contains(finalWindowName));
        } else {
            // 检查窗口名是否已存在
            if (windowSet.contains(windowName)) {
                // 如果已存在，添加序号后缀
                int counter = 1;
                QString newName = windowName;
                do {
                    newName = QString("%1(%2)").arg(windowName).arg(counter);
                    counter++;
                } while (windowSet.contains(newName));
                finalWindowName = newName;
            }
        }

        // 添加到这个节目下的窗口名集合
        windowSet.insert(finalWindowName);
    } else {
        // 如果父节点不存在于映射中，可能是根节点或其他情况
        // 这种情况下，我们只确保不与其他窗口重名
        if (windowName.isEmpty()) {
            finalWindowName = QString("窗口%1").arg(m_windowCounter);
            m_windowCounter++;
        }
    }

    int newWindowIndex = addNode(parentIndex, QJsonObject({
                                                  {"name", finalWindowName},
                                                  {"icon", "🖼"},
                                                  {"duration", "0.00s"},  // 初始为0
                                                  {"type", "window"}
                                              }));

    // 初始化这个窗口下的素材名集合
    m_materialNames[newWindowIndex] = QSet<QString>();

    qDebug() << "创建窗口节点:" << finalWindowName << "父节点:" << parentIndex << "索引:" << newWindowIndex;
}

// 辅助函数：从字符串中提取时长（秒）
double PlaylistTreeModel::extractDurationFromString(const QString& durationStr)
{
    if (durationStr.isEmpty()) return 0.0;

    // 移除末尾的's'字符
    QString cleanStr = durationStr.trimmed();
    if (cleanStr.endsWith('s')) {
        cleanStr = cleanStr.left(cleanStr.length() - 1);
    }

    bool ok = false;
    double duration = cleanStr.toDouble(&ok);
    return ok ? duration : 0.0;
}

// 辅助函数：将时长转换为字符串
QString PlaylistTreeModel::durationToString(double duration)
{
    return QString::number(duration, 'f', 2) + "s";
}

// 获取指定索引的节点显示数据
QJsonObject PlaylistTreeModel::getNodeDisplayData(int index) const
{
    if (index < 0 || index >= _tree_model.count()) {
        return QJsonObject();
    }

    // 获取节点数据
    auto nodeData = _tree_model.nodeData(index);
    if (nodeData.anyDataChanged()) {
        // 如果有数据变化，需要通知模型更新
        const_cast<PlaylistTreeModel*>(this)->_tree_model.dataUpdated(index);
    }

    // 获取用户数据的json对象
    return nodeData.userDataJsonObject(index);
}

// 更新节点的显示数据
void PlaylistTreeModel::updateNodeDisplayData(int index, const QJsonObject& displayData)
{
    if (index < 0 || index >= _tree_model.count()) {
        return;
    }

    // 获取节点数据对象
    auto nodeData = _tree_model.nodeData(index);

    // 遍历displayData中的所有键值对
    for (auto it = displayData.begin(); it != displayData.end(); ++it) {
        QString key = it.key();
        QVariant value = it.value().toVariant();
        nodeData.setKey(key, value);
    }

    // 通知模型数据已更新
    _tree_model.dataUpdated(index);
}

// 更新父节点时长的函数
void PlaylistTreeModel::updateParentDuration(int parentIndex)
{
    if (parentIndex < 0 || parentIndex >= _tree_model.count()) {
        return;
    }

    // 获取父节点的显示数据
    QJsonObject parentDisplayData = getNodeDisplayData(parentIndex);
    if (parentDisplayData.isEmpty()) {
        return;
    }

    double totalDuration = 0.0;
    int childCount = 0;

    // 获取父节点的深度
    int parentDepth = parentDisplayData[cDepthKey].toInt(-1);
    if (parentDepth < 0) {
        return;
    }

    // 遍历所有节点，找出父节点的所有直接子节点
    for (int i = 0; i < _tree_model.count(); i++) {
        if (i == parentIndex) continue;

        QJsonObject childDisplayData = getNodeDisplayData(i);
        if (childDisplayData.isEmpty()) continue;

        // 检查是否是直接子节点
        int childParentIndex = childDisplayData[cParentKey].toInt(-1);
        int childDepth = childDisplayData[cDepthKey].toInt(0);

        if (childParentIndex == parentIndex && childDepth == parentDepth + 1) {
            QString childDurationStr = childDisplayData["duration"].toString("0.00s");
            double childDuration = extractDurationFromString(childDurationStr);
            totalDuration += childDuration;
            childCount++;
        }
    }

    // 更新父节点的duration
    parentDisplayData["duration"] = durationToString(totalDuration);
    updateNodeDisplayData(parentIndex, parentDisplayData);

    qDebug() << "更新父节点" << parentIndex << "时长:" << durationToString(totalDuration)
             << "子节点数量:" << childCount << "名称:" << parentDisplayData["name"].toString();

    // 递归更新更上层的父节点
    int grandParentIndex = parentDisplayData[cParentKey].toInt(-1);
    if (grandParentIndex >= 0) {
        updateParentDuration(grandParentIndex);
    }
}

// 搜索子节点
QList<int> PlaylistTreeModel::searchChildren(int parentIndex) const
{
    QList<int> children;
    if (parentIndex < 0 || parentIndex >= _tree_model.count()) {
        return children;
    }

    // 获取父节点的深度
    QJsonObject parentDisplayData = getNodeDisplayData(parentIndex);
    int parentDepth = parentDisplayData[cDepthKey].toInt(-1);
    if (parentDepth < 0) {
        return children;
    }

    // 遍历所有节点，找出父节点的所有直接子节点
    for (int i = 0; i < _tree_model.count(); i++) {
        if (i == parentIndex) continue;

        QJsonObject childDisplayData = getNodeDisplayData(i);
        if (childDisplayData.isEmpty()) continue;

        int childParentIndex = childDisplayData[cParentKey].toInt(-1);
        int childDepth = childDisplayData[cDepthKey].toInt(0);

        if (childParentIndex == parentIndex && childDepth == parentDepth + 1) {
            children.append(i);
        }
    }

    return children;
}

void PlaylistTreeModel::createMaterialNode(int parentIndex, const QString& materialName, int materialIndex)
{
    QString finalMaterialName = materialName;

    // 获取父窗口节点下的素材名集合
    if (m_materialNames.contains(parentIndex)) {
        QSet<QString>& materialSet = m_materialNames[parentIndex];

        // 如果素材名为空，则生成默认素材名
        if (materialName.isEmpty()) {
            // 生成默认素材名
            int counter = 1;
            do {
                finalMaterialName = QString("素材%1").arg(counter);
                counter++;
            } while (materialSet.contains(finalMaterialName));
        } else {
            // 检查素材名是否已存在
            if (materialSet.contains(materialName)) {
                // 如果已存在，添加序号后缀
                int counter = 1;
                QString newName = materialName;
                do {
                    newName = QString("%1(%2)").arg(materialName).arg(counter);
                    counter++;
                } while (materialSet.contains(newName));
                finalMaterialName = newName;
            }
        }

        // 添加到这个窗口下的素材名集合
        materialSet.insert(finalMaterialName);
    } else {
        // 如果父节点不存在于映射中，初始化集合
        m_materialNames[parentIndex] = QSet<QString>();
        m_materialNames[parentIndex].insert(finalMaterialName);
    }

    // 默认素材时长
    double materialDuration = 1.11;  // 默认1.11秒

    qDebug() << "准备创建素材节点: 名称=" << finalMaterialName
             << "父节点索引=" << parentIndex
             << "当前节点总数=" << _tree_model.count();

    // 添加素材节点
    int newMaterialIndex = addNode(parentIndex, QJsonObject({
                                                    {"name", finalMaterialName},
                                                    {"icon", "📄"},
                                                    {"duration", durationToString(materialDuration)},
                                                    {"type", "material"}
                                                }));

    qDebug() << "创建素材节点完成: 索引=" << newMaterialIndex
             << "当前节点总数=" << _tree_model.count();

    // 获取新创建的素材节点数据，检查深度
    if (newMaterialIndex >= 0 && newMaterialIndex < _tree_model.count()) {
        QJsonObject newMaterialData = getNodeDisplayData(newMaterialIndex);
        int materialDepth = newMaterialData[cDepthKey].toInt(-1);
        int materialParentIndex = newMaterialData[cParentKey].toInt(-1);
        qDebug() << "素材节点信息: 深度=" << materialDepth
                 << "父节点索引=" << materialParentIndex
                 << "名称=" << newMaterialData["name"].toString();
    }

    // 获取父节点信息
    if (parentIndex >= 0 && parentIndex < _tree_model.count()) {
        QJsonObject parentData = getNodeDisplayData(parentIndex);
        int parentDepth = parentData[cDepthKey].toInt(-1);
        bool parentHasChildren = parentData[cHasChildendKey].toBool(false);
        qDebug() << "父节点信息: 索引=" << parentIndex
                 << "深度=" << parentDepth
                 << "名称=" << parentData["name"].toString()
                 << "有子节点=" << parentHasChildren;

        // 更新父窗口节点的时长
        updateParentDuration(parentIndex);
    } else {
        qDebug() << "父节点索引无效: " << parentIndex;
    }

    qDebug() << "创建素材节点:" << finalMaterialName
             << "父节点:" << parentIndex
             << "索引:" << newMaterialIndex
             << "时长:" << durationToString(materialDuration);


    qDebug() << "=== 节点层次结构调试 ===";
    qDebug() << "总节点数:" << _tree_model.count();

    for (int i = 0; i < _tree_model.count(); i++) {
        QJsonObject nodeData = getNodeDisplayData(i);
        if (!nodeData.isEmpty()) {
            QString name = nodeData["name"].toString("未知");
            int depth = nodeData[cDepthKey].toInt(-1);
            int parentIndex = nodeData[cParentKey].toInt(-1);
            bool hasChildren = nodeData[cHasChildendKey].toBool(false);
            bool expand = nodeData[cExpendKey].toBool(true);
            bool childrenExpand = nodeData[cChildrenExpendKey].toBool(false);

            qDebug() << QString("节点[%1]: 名称='%2' 深度=%3 父节点=%4 有子节点=%5 展开=%6 子节点展开=%7")
                            .arg(i).arg(name).arg(depth).arg(parentIndex)
                            .arg(hasChildren).arg(expand).arg(childrenExpand);
        }
    }
    qDebug() << "=== 结束 ===";
}
// 删除素材节点
void PlaylistTreeModel::removeMaterialNode(int index)
{
    if (index < 0 || index >= _tree_model.count()) {
        return;
    }

    // 获取要删除的节点的显示数据
    QJsonObject displayData = getNodeDisplayData(index);
    if (displayData.isEmpty()) {
        return;
    }

    int parentIndex = displayData[cParentKey].toInt(-1);
    QString materialName = displayData["name"].toString();
    QString type = displayData["type"].toString();

    // 只删除素材节点
    if (type != "material") {
        qDebug() << "只能删除素材节点，当前节点类型:" << type;
        return;
    }

    // 从素材名集合中移除
    if (m_materialNames.contains(parentIndex)) {
        m_materialNames[parentIndex].remove(materialName);
    }

    // 删除节点
    _tree_model.remove(index,
                       [this](int first, int last) {
                           // 开始删除行
                           this->beginRemoveRows(QModelIndex(), first, last);
                       },
                       [this]() {
                           // 结束删除行
                           this->endRemoveRows();
                       }
                       );

    // 更新父节点时长
    if (parentIndex >= 0 && parentIndex < _tree_model.count()) {
        updateParentDuration(parentIndex);
    }

    qDebug() << "删除素材节点:" << materialName << "索引:" << index;
}

// 更新素材节点的时长
void PlaylistTreeModel::updateMaterialDuration(int index, double newDuration)
{
    if (index < 0 || index >= _tree_model.count()) {
        return;
    }

    QJsonObject displayData = getNodeDisplayData(index);
    if (displayData.isEmpty()) {
        return;
    }

    QString type = displayData["type"].toString();
    if (type != "material") {
        qDebug() << "只能更新素材节点的时长，当前节点类型:" << type;
        return;
    }

    // 更新素材节点的时长
    displayData["duration"] = durationToString(newDuration);
    updateNodeDisplayData(index, displayData);

    // 更新父节点时长
    int parentIndex = displayData[cParentKey].toInt(-1);
    if (parentIndex >= 0) {
        updateParentDuration(parentIndex);
    }

    qDebug() << "更新素材节点时长:" << index << "新时长:" << durationToString(newDuration);
}
// PlaylistTreeModel.cpp 中实现

void PlaylistTreeModel::removeProgramNode(int index)
{
    if (index < 0 || index >= _tree_model.count())
        return;

    QJsonObject displayData = getNodeDisplayData(index);
    if (displayData.isEmpty() || displayData["type"].toString() != "program")
        return;

    QString programName = displayData["name"].toString();
    int parentIdx = displayData[cParentKey].toInt(-1);

    // 1. 从节目名集合中移除
    m_programNames.remove(programName);

    // 2. 收集该节目下的所有直接子窗口（节目→窗口）
    QList<int> windowIndices = searchChildren(index);
    for (int winIdx : windowIndices) {
        QJsonObject winData = getNodeDisplayData(winIdx);
        if (!winData.isEmpty()) {
            QString winName = winData["name"].toString();
            // 从父节目的窗口名集合中移除
            if (m_windowNames.contains(index)) {
                m_windowNames[index].remove(winName);
            }
        }
        // 清理该窗口对应的素材名集合
        if (m_materialNames.contains(winIdx)) {
            m_materialNames.remove(winIdx);
        }
    }

    // 3. 删除节目节点（模型会自动删除所有后代，如窗口和素材）
    _tree_model.remove(index,
                       [this](int first, int last) {
                           this->beginRemoveRows(QModelIndex(), first, last);
                       },
                       [this]() {
                           this->endRemoveRows();
                       });

    // 4. 清理节目中窗口名集合的残留映射
    if (m_windowNames.contains(index)) {
        m_windowNames.remove(index);
    }

    // 5. 如果有父节点，更新父节点时长（节目通常为顶层，但为了扩展性保留）
    if (parentIdx >= 0) {
        updateParentDuration(parentIdx);
    }

    qDebug() << "删除节目节点:" << programName << "索引:" << index;
}

void PlaylistTreeModel::removeWindowNode(int index)
{
    if (index < 0 || index >= _tree_model.count())
        return;

    QJsonObject displayData = getNodeDisplayData(index);
    if (displayData.isEmpty() || displayData["type"].toString() != "window")
        return;

    int parentProgramIndex = displayData[cParentKey].toInt(-1);
    QString windowName = displayData["name"].toString();

    // 1. 从父节目的窗口名集合中移除
    if (parentProgramIndex >= 0 && m_windowNames.contains(parentProgramIndex)) {
        m_windowNames[parentProgramIndex].remove(windowName);
    }

    // 2. 清理该窗口对应的素材名集合
    if (m_materialNames.contains(index)) {
        m_materialNames.remove(index);
    }

    // 3. 删除窗口节点（模型会自动删除其下的所有素材）
    _tree_model.remove(index,
                       [this](int first, int last) {
                           this->beginRemoveRows(QModelIndex(), first, last);
                       },
                       [this]() {
                           this->endRemoveRows();
                       });

    // 4. 更新父节目节点的时长
    if (parentProgramIndex >= 0) {
        updateParentDuration(parentProgramIndex);
    }

    qDebug() << "删除窗口节点:" << windowName << "索引:" << index;
}