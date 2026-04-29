#include "mediasourceservice.h"

// services/MediaSourceService.cpp
// #include "MediaSourceService.h"
#include "../repositories/RepositoryFactory.h"
#include "../databasemanager.h"
#include "../../utils/datetimehelper.h"
#include "AuditLogService.h"
#include <QDateTime>

using namespace Repository;
using namespace LEDDB;


bool MediaSourceService::addMedia(const MediaSource& media, const QString& operatorUser) {
    std::unique_ptr<IMediaSourceRepository>   mediaRepo = RepositoryFactory::createMediaSourceRepository();
    MediaSource newMedia = media;
    newMedia.setCreateTime(QDateTime::currentDateTime());
    bool success = mediaRepo->insert(newMedia);

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    AuditLogService().logOperation(userId, "添加素材", success ? "成功" : "失败",
                                   QString("向视窗 %1 添加素材 %2").arg(media.windowId()).arg(media.filePath()),
                                   "media_source", newMedia.mediaId());
    return success;
}

bool MediaSourceService::updateMedia(const MediaSource& media, const QString& operatorUser) {
    auto mediaRepo = RepositoryFactory::createMediaSourceRepository();
    bool success = mediaRepo->update(media);

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    AuditLogService().logOperation(userId, "更新素材", success ? "成功" : "失败",
                                   QString("更新素材 ID=%1").arg(media.mediaId()),
                                   "media_source", media.mediaId());
    return success;
}

bool MediaSourceService::removeMedia(int mediaId, const QString& operatorUser) {
    auto mediaRepo = RepositoryFactory::createMediaSourceRepository();
    auto media = mediaRepo->findById(mediaId);
    if (!media) return false;

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    bool success = mediaRepo->deleteById(mediaId);
    AuditLogService().logOperation(userId, "删除素材", success ? "成功" : "失败",
                                   QString("删除素材 %1").arg(media->filePath()),
                                   "media_source", mediaId);
    return success;
}

std::optional<MediaSource> MediaSourceService::getMediaById(int mediaId) {
    auto mediaRepo = RepositoryFactory::createMediaSourceRepository();
    return mediaRepo->findById(mediaId);
}

QList<MediaSource> MediaSourceService::getMediaByWindow(int windowId) {
    auto mediaRepo = RepositoryFactory::createMediaSourceRepository();
    return mediaRepo->findByWindowId(windowId);
}

bool MediaSourceService::reorderMedia(int windowId, const QList<int>& mediaIdsInOrder, const QString& operatorUser) {
    if (mediaIdsInOrder.isEmpty()) return true;

    int userId = 0;
    auto userRepo = RepositoryFactory::createUserRepository();
    auto userOpt = userRepo->findByUserName(operatorUser);
    if (userOpt.has_value()) {
        userId = userOpt.value().userId();
    }

    DatabaseManager& dbMgr = DatabaseManager::instance();
    if (!dbMgr.beginTransaction()) return false;

    bool success = true;
    for (int i = 0; i < mediaIdsInOrder.size(); ++i) {
        auto media = getMediaById(mediaIdsInOrder[i]);
        if (!media || media->windowId() != windowId) {
            success = false;
            break;
        }
        MediaSource updated = *media;
        updated.setMediaSort(i);
        if (!RepositoryFactory::createMediaSourceRepository()->update(updated)) {
            success = false;
            break;
        }
    }

    if (success && dbMgr.commitTransaction()) {
        AuditLogService().logOperation(userId, "重排素材", "成功",
                                       QString("视窗 %1 素材顺序已调整").arg(windowId),
                                       "media_source", windowId);
        return true;
    } else {
        dbMgr.rollbackTransaction();
        AuditLogService().logOperation(userId, "重排素材", "失败",
                                       QString("视窗 %1 素材顺序调整失败").arg(windowId),
                                       "media_source", windowId);
        return false;
    }
}