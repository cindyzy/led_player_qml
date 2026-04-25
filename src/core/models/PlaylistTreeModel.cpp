#include "PlaylistTreeModel.h"
#include <QDebug>

PlaylistTreeModel::PlaylistTreeModel(QObject* parent)
    : TreeViewModel(parent)
{
}

PlaylistTreeModel::~PlaylistTreeModel()
{
}

void PlaylistTreeModel::initializeModel()
{
    clear();
    

    
}

void PlaylistTreeModel::createProgramNode(int parentIndex, const QString& programName, int programIndex)
{
    addNode(-1, QJsonObject({
                    {"name", programName},
                    {"icon", "📁"},
                    {"duration", "10.00s"},
                    {"type", "program"}
                }));



}

void PlaylistTreeModel::createWindowNode(int parentIndex, const QString& windowName, int windowIndex)
{
    addNode(parentIndex, QJsonObject({
                             {"name", windowName},
                             {"icon", "🖼"},
                             {"duration", "3.33s"},
                             {"type", "window"}
                         }));
    for (int i = 1; i <= 3; ++i) {
        QString materialName = QString("素材%1-%2").arg(windowIndex).arg(i);

    }
}
void PlaylistTreeModel::createMaterialNode(int parentIndex, const QString& materialName, int materialIndex)
{
    addNode(parentIndex, QJsonObject({
                             {"name", materialName},
                             {"icon", "📄"},
                             {"duration", "1.11s"},
                             {"type", "material"}
                         }));
}