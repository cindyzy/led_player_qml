cmake_minimum_required(VERSION 3.16)
project(LedPlayer VERSION 1.0.0 LANGUAGES CXX)

# 设置C++标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 设置Qt相关自动处理
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 查找Qt6组件
find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickControls2 Sql Multimedia )

# 设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# 添加可执行目标
add_executable(LedPlayer
    src/utils/charbitmapgenerator.h
    src/utils/charbitmapgenerator.cpp
    src/utils/filehelper.h src/utils/filehelper.cpp
    src/core/models/tree/CppTreeModel.h
    src/core/models/tree/ModelDataAdapter.h
    src/core/models/tree/treeviewmodel.cpp
    src/core/models/tree/include/TreeViewListModel.h
    src/core/models/tree/include/TreeViewListModel.inl
    src/core/models/tree/include/treeviewmodel.h
    src/core/models/PlaylistTreeModel.h
    src/core/models/PlaylistTreeModel.cpp
    src/core/models/entity/UserModel.h src/core/models/entity/UserModel.cpp
    src/core/models/entity/RoleModel.h src/core/models/entity/RoleModel.cpp
    src/core/models/entity/PermissionModel.h src/core/models/entity/PermissionModel.cpp
    src/core/models/entity/LedDeviceModel.h src/core/models/entity/LedDeviceModel.cpp
    src/core/models/entity/ProjectConfigModel.h src/core/models/entity/ProjectConfigModel.cpp
    src/core/models/entity/PlayListModel.h src/core/models/entity/PlayListModel.cpp
    src/core/models/entity/ProgramInfoModel.h src/core/models/entity/ProgramInfoModel.cpp
    src/core/models/entity/WindowViewModel.h src/core/models/entity/WindowViewModel.cpp
    src/core/models/entity/MediaSourceModel.h src/core/models/entity/MediaSourceModel.cpp
    src/core/models/entity/ScheduleParamModel.h src/core/models/entity/ScheduleParamModel.cpp
    src/core/models/entity/AiModelConfigModel.h src/core/models/entity/AiModelConfigModel.cpp
    src/core/models/entity/SceneStatisticModel.h src/core/models/entity/SceneStatisticModel.cpp
    src/core/models/entity/AuditLogModel.h src/core/models/entity/AuditLogModel.cpp
    src/database/databasemanager.h src/database/databasemanager.cpp
    src/database/scopedtransaction.h src/database/scopedtransaction.cpp

    src/database/entities/user.h src/database/entities/user.cpp
    src/utils/datetimehelper.h
    src/database/entities/role.h src/database/entities/role.cpp
    src/database/entities/permission.h src/database/entities/permission.cpp
    src/database/entities/leddevice.h src/database/entities/leddevice.cpp
    src/database/entities/projectconfig.h src/database/entities/projectconfig.cpp
    src/database/entities/playlist.h src/database/entities/playlist.cpp
    src/database/entities/programinfo.h src/database/entities/programinfo.cpp
    src/database/entities/windowview.h src/database/entities/windowview.cpp
    src/database/entities/mediasource.h src/database/entities/mediasource.cpp
    src/database/entities/scheduleparam.h src/database/entities/scheduleparam.cpp
    src/utils/cryptohelper.h src/utils/cryptohelper.cpp
    src/database/entities/aimodelconfig.h src/database/entities/aimodelconfig.cpp
    src/database/entities/scenestatistic.h src/database/entities/scenestatistic.cpp
    src/database/entities/auditlog.h src/database/entities/auditlog.cpp
    src/database/repositories/interfaces/IRoleRepository.h
    src/database/repositories/interfaces/IPermissionRepository.h
    src/database/repositories/interfaces/ILedDeviceRepository.h
    src/database/repositories/interfaces/IProjectConfigRepository.h
    src/database/repositories/interfaces/IPlayListRepository.h
    src/database/repositories/interfaces/IProgramInfoRepository.h
    src/database/repositories/interfaces/IWindowViewRepository.h
    src/database/repositories/interfaces/IMediaSourceRepository.h
    src/database/repositories/interfaces/IScheduleParamRepository.h
    src/database/repositories/interfaces/IAiModelConfigRepository.h
    src/database/repositories/interfaces/ISceneStatisticRepository.h
    src/database/repositories/interfaces/IAuditLogRepository.h
    src/database/repositories/sqliteuserrepository.h
    src/database/repositories/sqliteuserrepository.cpp
    src/database/repositories/sqliterolerepository.h
    src/database/repositories/sqliterolerepository.cpp
    src/database/repositories/interfaces/IAiModelConfigRepository.h
    src/database/repositories/interfaces/IAuditLogRepository.h
    src/database/repositories/interfaces/ILedDeviceRepository.h
    src/database/repositories/interfaces/IMediaSourceRepository.h
    src/database/repositories/interfaces/IPermissionRepository.h
    src/database/repositories/interfaces/IPlayListRepository.h
    src/database/repositories/interfaces/IProgramInfoRepository.h
    src/database/repositories/interfaces/IProjectConfigRepository.h
    src/database/repositories/interfaces/IRoleRepository.h
    src/database/repositories/interfaces/ISceneStatisticRepository.h
    src/database/repositories/interfaces/IScheduleParamRepository.h
    src/database/repositories/interfaces/IUserRepository.h
    src/database/repositories/interfaces/IWindowViewRepository.h
    src/database/repositories/repositoryfactory.h
    src/database/repositories/sqlitepermissionrepository.h src/database/repositories/sqlitepermissionrepository.cpp
    src/database/repositories/sqliteleddevicerepository.h src/database/repositories/sqliteleddevicerepository.cpp
    src/database/repositories/sqliteprojectconfigrepository.h src/database/repositories/sqliteprojectconfigrepository.cpp
    src/database/repositories/sqliteplaylistrepository.h src/database/repositories/sqliteplaylistrepository.cpp
    src/database/repositories/sqliteprograminforepository.h src/database/repositories/sqliteprograminforepository.cpp
    src/database/repositories/sqlitewindowviewrepository.h src/database/repositories/sqlitewindowviewrepository.cpp
    src/database/repositories/sqlitemediasourcerepository.h src/database/repositories/sqlitemediasourcerepository.cpp
    src/database/repositories/sqlitescheduleparamrepository.h src/database/repositories/sqlitescheduleparamrepository.cpp
    src/database/repositories/sqliteaimodelconfigrepository.h src/database/repositories/sqliteaimodelconfigrepository.cpp
    src/database/repositories/sqlitescenestatisticrepository.h src/database/repositories/sqlitescenestatisticrepository.cpp
    src/database/repositories/sqliteauditlogrepository.h src/database/repositories/sqliteauditlogrepository.cpp
    src/database/repositories/repositoryfactory.cpp
    src/database/services/userservice.h src/database/services/userservice.cpp
    src/database/services/roleservice.h src/database/services/roleservice.cpp
    src/database/services/permissionservice.h src/database/services/permissionservice.cpp
    src/database/services/leddeviceservice.h src/database/services/leddeviceservice.cpp
    src/database/services/projectconfigservice.h src/database/services/projectconfigservice.cpp
    src/database/services/playlistservice.h src/database/services/playlistservice.cpp
    src/database/services/programinfoservice.h src/database/services/programinfoservice.cpp
    src/database/services/windowviewservice.h src/database/services/windowviewservice.cpp
    src/database/services/mediasourceservice.h src/database/services/mediasourceservice.cpp
    src/database/services/scheduleparamservice.h src/database/services/scheduleparamservice.cpp
    src/database/services/aimodelconfigservice.h src/database/services/aimodelconfigservice.cpp
    src/database/services/scenestatisticservice.h src/database/services/scenestatisticservice.cpp
    src/database/services/auditlogservice.h src/database/services/auditlogservice.cpp
    src/business/businesscontroller.h src/business/businesscontroller.cpp



)

# 设置目标属性
set_target_properties(LedPlayer PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

# 设置目标源文件
target_sources(LedPlayer PRIVATE
    src/app/main.cpp
    src/qml/qml.qrc

)

# 链接Qt库
target_link_libraries(LedPlayer PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Sql
    Qt6::Multimedia
)

# 设置安装目标
install(TARGETS LedPlayer
    RUNTIME DESTINATION bin
    BUNDLE DESTINATION .
    LIBRARY DESTINATION lib
)
