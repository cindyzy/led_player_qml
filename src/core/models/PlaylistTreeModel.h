#ifndef PLAYLIST_TREE_MODEL_H
#define PLAYLIST_TREE_MODEL_H

#include "tree/include/treeviewmodel.h"
#include <QJsonObject>
#include <QJsonArray>
#include <QString>
#include <QObject>

class PlaylistTreeModel : public TreeViewModel
{
    Q_OBJECT
    
public:
    explicit PlaylistTreeModel(QObject* parent = nullptr);
    ~PlaylistTreeModel();
    
    Q_INVOKABLE void initializeModel();
    
// private:
    Q_INVOKABLE void createProgramNode(int parentIndex, const QString& programName, int programIndex);
    Q_INVOKABLE void createWindowNode(int parentIndex, const QString& windowName, int windowIndex);
    Q_INVOKABLE void createMaterialNode(int parentIndex, const QString& materialName, int materialIndex);

};

#endif // PLAYLIST_TREE_MODEL_H
