#ifndef PLAYLIST_TREE_MODEL_H
#define PLAYLIST_TREE_MODEL_H
// PlaylistTreeModel.h
#include "tree/include/treeviewmodel.h"

#include <QSet>
#include <QString>
#include <QMap>

class PlaylistTreeModel : public TreeViewModel
{
    Q_OBJECT
public:
    explicit PlaylistTreeModel(QObject* parent = nullptr);
    ~PlaylistTreeModel();

    Q_INVOKABLE void initializeModel();
    Q_INVOKABLE void createProgramNode(int parentIndex, const QString& programName="", int programIndex=1);
    Q_INVOKABLE void createWindowNode(int parentIndex, const QString& windowName="", int windowIndex=1);
    Q_INVOKABLE void createMaterialNode(int parentIndex, const QString& materialName="", int materialIndex=1);
    Q_INVOKABLE void removeMaterialNode(int index);
    Q_INVOKABLE void updateMaterialDuration(int index, double newDuration);
    Q_INVOKABLE void removeProgramNode(int index);
    Q_INVOKABLE void removeWindowNode(int index);

private:
    int m_programCounter; // 节目计数器
    int m_windowCounter;  // 窗口计数器
    QSet<QString> m_programNames; // 已使用的节目名集合
    QMap<int, QSet<QString>> m_windowNames; // 节目ID -> 窗口名集合
    QMap<int, QSet<QString>> m_materialNames; // 窗口ID -> 素材名集合

    // 辅助函数
    double extractDurationFromString(const QString& durationStr);
    QString durationToString(double duration);

    // 节点数据操作函数
    QJsonObject getNodeDisplayData(int index) const;
    void updateNodeDisplayData(int index, const QJsonObject& displayData);

    // 更新父节点时长的函数
    void updateParentDuration(int parentIndex);

    // 搜索子节点
    QList<int> searchChildren(int parentIndex) const;
};

#endif // PLAYLISTTREEMODEL_H