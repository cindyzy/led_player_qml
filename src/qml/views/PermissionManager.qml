import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

// 权限管理组件
Rectangle {
    id: permissionContainer
    anchors.fill: parent
    color: "#252526"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 标签页
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            background: Rectangle {
                color: "#1E1E1E"
            }

            TabButton {
                text: "用户管理"
                width: implicitWidth
                background: Rectangle {
                    color: tabBar.currentIndex === 0 ? "#3D3D3D" : "#1E1E1E"
                    border.color: "#00D4AA"
                    border.width: tabBar.currentIndex === 0 ? 2 : 0
                }
                contentItem: Text {
                    text: parent.text
                    color: tabBar.currentIndex === 0 ? "#FFFFFF" : "#888888"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                }
            }

            TabButton {
                text: "角色管理"
                width: implicitWidth
                background: Rectangle {
                    color: tabBar.currentIndex === 1 ? "#3D3D3D" : "#1E1E1E"
                    border.color: "#00D4AA"
                    border.width: tabBar.currentIndex === 1 ? 2 : 0
                }
                contentItem: Text {
                    text: parent.text
                    color: tabBar.currentIndex === 1 ? "#FFFFFF" : "#888888"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                }
            }

            TabButton {
                text: "权限管理"
                width: implicitWidth
                background: Rectangle {
                    color: tabBar.currentIndex === 2 ? "#3D3D3D" : "#1E1E1E"
                    border.color: "#00D4AA"
                    border.width: tabBar.currentIndex === 2 ? 2 : 0
                }
                contentItem: Text {
                    text: parent.text
                    color: tabBar.currentIndex === 2 ? "#FFFFFF" : "#888888"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                }
            }
        }

        // 内容区域
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            // 用户管理
            Rectangle {
                color: "#252526"
                anchors.fill: parent

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // 工具栏
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: "#1E1E1E"
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            TextField {
                                id: userSearchField
                                Layout.preferredWidth: 200
                                placeholderText: "搜索用户名..."
                            }

                            Button {
                                text: "新建用户"
                                onClicked: {
                                    showUserDialog(null)
                                }
                            }

                            Button {
                                text: "刷新列表"
                                onClicked: {
                                    userModel.loadUsers()
                                }
                            }
                        }
                    }

                    // 用户列表
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#252526"

                        ListView {
                            id: userListView
                            anchors.fill: parent
                            anchors.margins: 10
                            clip: true
                            spacing: 5
                            model: userModel

                            delegate: Rectangle {
                                width: parent.width
                                height: 90
                                color: "#2D2D2D"
                                radius: 4
                                border.color: "#3D3D3D"
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8

                                    // 用户名和状态
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 15

                                        Text {
                                            text: model.userName
                                            color: "#FFFFFF"
                                            font.pixelSize: 16
                                            font.bold: true
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 80
                                            Layout.preferredHeight: 24
                                            radius: 12
                                            color: model.status === 1 ? "#00D4AA" : "#FF6B6B"
                                            Text {
                                                anchors.centerIn: parent
                                                text: model.status === 1 ? "正常" : "禁用"
                                                color: "#000000"
                                                font.pixelSize: 11
                                                font.bold: true
                                            }
                                        }

                                        Text {
                                            text: "角色ID: " + model.roleId
                                            color: "#888888"
                                            font.pixelSize: 12
                                        }

                                        Text {
                                            text: model.createTime
                                            color: "#888888"
                                            font.pixelSize: 12
                                            Layout.alignment: Qt.AlignRight
                                        }
                                    }

                                    // 用户信息
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 20

                                        Text {
                                            text: "用户ID: " + model.userId
                                            color: "#888888"
                                            font.pixelSize: 12
                                        }

                                        Text {
                                            text: "最后登录: " + (model.lastLoginTime || "从未登录")
                                            color: "#888888"
                                            font.pixelSize: 12
                                        }
                                    }

                                    // 操作按钮
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10
                                        Layout.alignment: Qt.AlignRight

                                        Button {
                                            text: model.status === 1 ? "禁用" : "启用"
                                            // color: model.status === 1 ? "#FF6B6B" : "#00D4AA"
                                            onClicked: {
                                                userModel.updateUser(
                                                    model.userId,
                                                    model.userName,
                                                    "",
                                                    model.roleId,
                                                    model.status === 1 ? 0 : 1,
                                                    "system"
                                                )
                                            }
                                        }

                                        Button {
                                            text: "编辑"
                                            onClicked: {
                                                showUserDialog(model.userId)
                                            }
                                        }

                                        Button {
                                            text: "删除"
                                            // color: "#FF6B6B"
                                            onClicked: {
                                                if (confirmDelete("用户", model.userName, model.userId)) {
                                                    userModel.deleteUser(model.userId, "system")
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            header: Rectangle {
                                width: parent.width
                                height: 35
                                color: "#1E1E1E"
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 20

                                    Text {
                                        text: "用户名"
                                        color: "#888888"
                                        font.pixelSize: 12
                                        font.bold: true
                                        width: 150
                                    }

                                    Text {
                                        text: "状态"
                                        color: "#888888"
                                        font.pixelSize: 12
                                        font.bold: true
                                        width: 80
                                    }

                                    Text {
                                        text: "创建时间"
                                        color: "#888888"
                                        font.pixelSize: 12
                                        font.bold: true
                                        width: 150
                                    }

                                    Text {
                                        text: "操作"
                                        color: "#888888"
                                        font.pixelSize: 12
                                        font.bold: true
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 角色管理
            Rectangle {
                color: "#252526"
                anchors.fill: parent

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // 工具栏
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: "#1E1E1E"
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            TextField {
                                id: roleSearchField
                                Layout.preferredWidth: 200
                                placeholderText: "搜索角色名..."
                            }

                            Button {
                                text: "新建角色"
                                onClicked: {
                                    showRoleDialog(null)
                                }
                            }

                            Button {
                                text: "刷新列表"
                                onClicked: {
                                    roleModel.loadRoles()
                                }
                            }
                        }
                    }

                    // 角色列表
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#252526"

                        ListView {
                            id: roleListView
                            anchors.fill: parent
                            anchors.margins: 10
                            clip: true
                            spacing: 5
                            model: roleModel

                            delegate: Rectangle {
                                width: parent.width
                                height: 80
                                color: "#2D2D2D"
                                radius: 4
                                border.color: "#3D3D3D"
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8

                                    // 角色名
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 15

                                        Text {
                                            text: model.roleName
                                            color: "#FFFFFF"
                                            font.pixelSize: 16
                                            font.bold: true
                                        }

                                        Text {
                                            text: "角色ID: " + model.roleId
                                            color: "#888888"
                                            font.pixelSize: 12
                                        }
                                    }

                                    // 角色描述
                                    Text {
                                        text: "描述: " + (model.roleDesc || "无描述")
                                        color: "#888888"
                                        font.pixelSize: 12
                                        Layout.fillWidth: true
                                        wrapMode: Text.Wrap
                                    }

                                    // 操作按钮
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10
                                        Layout.alignment: Qt.AlignRight

                                        Button {
                                            text: "编辑"
                                            onClicked: {
                                                showRoleDialog(model.roleId)
                                            }
                                        }

                                        Button {
                                            text: "删除"
                                            // color: "#FF6B6B"
                                            onClicked: {
                                                if (confirmDelete("角色", model.roleName, model.roleId)) {
                                                    roleModel.deleteRole(model.roleId, "system")
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            header: Rectangle {
                                width: parent.width
                                height: 35
                                color: "#1E1E1E"
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 20

                                    Text {
                                        text: "角色名称"
                                        color: "#888888"
                                        font.pixelSize: 12
                                        font.bold: true
                                        width: 200
                                    }

                                    Text {
                                        text: "操作"
                                        color: "#888888"
                                        font.pixelSize: 12
                                        font.bold: true
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 权限管理
            Rectangle {
                color: "#252526"
                anchors.fill: parent

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // 工具栏
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: "#1E1E1E"
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            TextField {
                                id: permSearchField
                                Layout.preferredWidth: 200
                                placeholderText: "搜索权限代码..."
                            }

                            Button {
                                text: "新建权限"
                                onClicked: {
                                    showPermissionDialog(null)
                                }
                            }

                            Button {
                                text: "刷新列表"
                                onClicked: {
                                    permissionModel.loadPermissions()
                                }
                            }
                        }
                    }

                    // 权限列表
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#252526"

                        ListView {
                            id: permListView
                            anchors.fill: parent
                            anchors.margins: 10
                            clip: true
                            spacing: 5
                            model: permissionModel

                            delegate: Rectangle {
                                width: parent.width
                                height: 80
                                color: "#2D2D2D"
                                radius: 4
                                border.color: "#3D3D3D"
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8

                                    // 权限代码
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 15

                                        Text {
                                            text: model.permCode
                                            color: "#00D4AA"
                                            font.pixelSize: 14
                                            font.bold: true
                                        }

                                        Text {
                                            text: "角色ID: " + model.roleId
                                            color: "#888888"
                                            font.pixelSize: 12
                                        }

                                        Text {
                                            text: "权限ID: " + model.permId
                                            color: "#888888"
                                            font.pixelSize: 12
                                        }
                                    }

                                    // 权限描述
                                    Text {
                                        text: "描述: " + (model.permDesc || "无描述")
                                        color: "#888888"
                                        font.pixelSize: 12
                                        Layout.fillWidth: true
                                        wrapMode: Text.Wrap
                                    }

                                    // 操作按钮
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10
                                        Layout.alignment: Qt.AlignRight

                                        Button {
                                            text: "编辑"
                                            onClicked: {
                                                showPermissionDialog(model.permId)
                                            }
                                        }

                                        Button {
                                            text: "删除"
                                            // color: "#FF6B6B"
                                            onClicked: {
                                                if (confirmDelete("权限", model.permCode, model.permId)) {
                                                    permissionModel.deletePermission(model.permId, "system")
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            header: Rectangle {
                                width: parent.width
                                height: 35
                                color: "#1E1E1E"
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 20

                                    Text {
                                        text: "权限代码"
                                        color: "#888888"
                                        font.pixelSize: 12
                                        font.bold: true
                                        width: 200
                                    }

                                    Text {
                                        text: "操作"
                                        color: "#888888"
                                        font.pixelSize: 12
                                        font.bold: true
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // 用户对话框
    Component {
        id: userDialogComponent
        Rectangle {
            id: userDialog
            width: 400
            height: 300
            color: "#252526"
            radius: 8
            border.color: "#3D3D3D"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15
                anchors.margins: 20

                // 标题
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: isEditMode ? "编辑用户" : "新建用户"
                        color: "#FFFFFF"
                        font.pixelSize: 18
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: "×"
                        // color: "#888888"
                        onClicked: {
                            userDialog.visible = false
                        }
                    }
                }

                // 用户名
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "用户名 *"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    TextField {
                        id: userNameField
                        Layout.fillWidth: true
                        placeholderText: "请输入用户名"
                    }
                }

                // 密码
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: isEditMode ? "密码（留空不修改）" : "密码 *"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    TextField {
                        id: passwordField
                        Layout.fillWidth: true
                        placeholderText: "请输入密码"
                        echoMode: TextInput.Password
                    }
                }

                // 角色ID
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "角色ID *"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    TextField {
                        id: roleIdField
                        Layout.fillWidth: true
                        placeholderText: "请输入角色ID"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }
                }

                // 按钮
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    Layout.alignment: Qt.AlignRight

                    Button {
                        text: "取消"
                        onClicked: {
                            userDialog.visible = false
                        }
                    }

                    Button {
                        text: isEditMode ? "保存" : "创建"
                        onClicked: {
                            saveUser(userDialog)
                        }
                    }
                }
            }
        }
    }

    // 角色对话框
    Component {
        id: roleDialogComponent
        Rectangle {
            id: roleDialog
            width: 400
            height: 250
            color: "#252526"
            radius: 8
            border.color: "#3D3D3D"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15
                anchors.margins: 20

                // 标题
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: isEditMode ? "编辑角色" : "新建角色"
                        color: "#FFFFFF"
                        font.pixelSize: 18
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: "×"
                        // color: "#888888"
                        onClicked: {
                            roleDialog.visible = false
                        }
                    }
                }

                // 角色名
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "角色名称 *"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    TextField {
                        id: roleNameField
                        Layout.fillWidth: true
                        placeholderText: "请输入角色名称"
                    }
                }

                // 角色描述
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "角色描述"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    TextField {
                        id: roleDescField
                        Layout.fillWidth: true
                        placeholderText: "请输入角色描述"
                    }
                }

                // 按钮
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    Layout.alignment: Qt.AlignRight

                    Button {
                        text: "取消"
                        onClicked: {
                            roleDialog.visible = false
                        }
                    }

                    Button {
                        text: isEditMode ? "保存" : "创建"
                        onClicked: {
                            saveRole(roleDialog)
                        }
                    }
                }
            }
        }
    }

    // 权限对话框
    Component {
        id: permissionDialogComponent
        Rectangle {
            id: permissionDialog
            width: 400
            height: 300
            color: "#252526"
            radius: 8
            border.color: "#3D3D3D"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15
                anchors.margins: 20

                // 标题
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: isEditMode ? "编辑权限" : "新建权限"
                        color: "#FFFFFF"
                        font.pixelSize: 18
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: "×"
                        // color: "#888888"
                        onClicked: {
                            permissionDialog.visible = false
                        }
                    }
                }

                // 角色ID
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "角色ID *"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    TextField {
                        id: permRoleIdField
                        Layout.fillWidth: true
                        placeholderText: "请输入角色ID"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }
                }

                // 权限代码
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "权限代码 *"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    TextField {
                        id: permCodeField
                        Layout.fillWidth: true
                        placeholderText: "例如: user:read, user:write"
                    }
                }

                // 权限描述
                ColumnLayout {
                    spacing: 5
                    Text {
                        text: "权限描述"
                        color: "#888888"
                        font.pixelSize: 12
                    }
                    TextField {
                        id: permDescField
                        Layout.fillWidth: true
                        placeholderText: "请输入权限描述"
                    }
                }

                // 按钮
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    Layout.alignment: Qt.AlignRight

                    Button {
                        text: "取消"
                        onClicked: {
                            permissionDialog.visible = false
                        }
                    }

                    Button {
                        text: isEditMode ? "保存" : "创建"
                        onClicked: {
                            savePermission(permissionDialog)
                        }
                    }
                }
            }
        }
    }

    // 确认对话框
    Component {
        id: confirmDialogComponent
        Rectangle {
            id: confirmDialog
            width: 350
            height: 150
            color: "#252526"
            radius: 8
            border.color: "#3D3D3D"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 15
                anchors.margins: 20

                Text {
                    text: "确认删除"
                    color: "#FFFFFF"
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    text: "确定要删除" + confirmType + " '" + confirmName + "' 吗？"
                    color: "#888888"
                    font.pixelSize: 13
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    Layout.alignment: Qt.AlignRight

                    Button {
                        text: "取消"
                        onClicked: {
                            confirmDialog.visible = false
                        }
                    }

                    Button {
                        text: "删除"
                        // color: "#FF6B6B"
                        onClicked: {
                            confirmDialog.visible = false
                            if (confirmCallback) {
                                confirmCallback()
                            }
                        }
                    }
                }
            }
        }
    }

    // 状态变量
    property bool isEditMode: false
    property int editingId: 0
    property string confirmType: ""
    property string confirmName: ""
    property var confirmCallback: null

    // 显示用户对话框
    function showUserDialog(userId) {
        isEditMode = userId !== null

        var dialog = userDialogComponent.createObject(permissionContainer.parent)

        if (isEditMode) {
            editingId = userId
            var userData = userModel.findUserById(userId)
            if (userData) {
                dialog.userNameField.text = userData.userName || ""
                dialog.passwordField.text = ""
                dialog.roleIdField.text = userData.roleId || ""
            }
        } else {
            dialog.userNameField.text = ""
            dialog.passwordField.text = ""
            dialog.roleIdField.text = ""
        }

        dialog.visible = true
        dialog.x = (permissionContainer.width - dialog.width) / 2
        dialog.y = (permissionContainer.height - dialog.height) / 2
    }

    // 保存用户
    function saveUser(dialog) {
        if (!dialog.userNameField.text.trim() || !dialog.roleIdField.text.trim()) {
            return
        }

        if (isEditMode) {
            userModel.updateUser(
                editingId,
                dialog.userNameField.text,
                dialog.passwordField.text,
                parseInt(dialog.roleIdField.text),
                1,
                "system"
            )
        } else {
            if (!dialog.passwordField.text.trim()) {
                return
            }
            userModel.addUser(
                dialog.userNameField.text,
                dialog.passwordField.text,
                parseInt(dialog.roleIdField.text),
                "system"
            )
        }

        dialog.visible = false
    }

    // 显示角色对话框
    function showRoleDialog(roleId) {
        isEditMode = roleId !== null

        var dialog = roleDialogComponent.createObject(permissionContainer.parent)

        if (isEditMode) {
            editingId = roleId
            var roleData = roleModel.findRoleById(roleId)
            if (roleData) {
                dialog.roleNameField.text = roleData.roleName || ""
                dialog.roleDescField.text = roleData.roleDesc || ""
            }
        } else {
            dialog.roleNameField.text = ""
            dialog.roleDescField.text = ""
        }

        dialog.visible = true
        dialog.x = (permissionContainer.width - dialog.width) / 2
        dialog.y = (permissionContainer.height - dialog.height) / 2
    }

    // 保存角色
    function saveRole(dialog) {
        if (!dialog.roleNameField.text.trim()) {
            return
        }

        if (isEditMode) {
            roleModel.updateRole(
                editingId,
                dialog.roleNameField.text,
                dialog.roleDescField.text,
                "system"
            )
        } else {
            roleModel.addRole(
                dialog.roleNameField.text,
                dialog.roleDescField.text,
                "system"
            )
        }

        dialog.visible = false
    }

    // 显示权限对话框
    function showPermissionDialog(permId) {
        isEditMode = permId !== null

        var dialog = permissionDialogComponent.createObject(permissionContainer.parent)

        if (isEditMode) {
            editingId = permId
            var permData = permissionModel.findPermissionById(permId)
            if (permData) {
                dialog.permRoleIdField.text = permData.roleId || ""
                dialog.permCodeField.text = permData.permCode || ""
                dialog.permDescField.text = permData.permDesc || ""
            }
        } else {
            dialog.permRoleIdField.text = ""
            dialog.permCodeField.text = ""
            dialog.permDescField.text = ""
        }

        dialog.visible = true
        dialog.x = (permissionContainer.width - dialog.width) / 2
        dialog.y = (permissionContainer.height - dialog.height) / 2
    }

    // 保存权限
    function savePermission(dialog) {
        if (!dialog.permRoleIdField.text.trim() || !dialog.permCodeField.text.trim()) {
            return
        }

        if (isEditMode) {
            permissionModel.updatePermission(
                editingId,
                parseInt(dialog.permRoleIdField.text),
                dialog.permCodeField.text,
                dialog.permDescField.text,
                "system"
            )
        } else {
            permissionModel.addPermission(
                parseInt(dialog.permRoleIdField.text),
                dialog.permCodeField.text,
                dialog.permDescField.text,
                "system"
            )
        }

        dialog.visible = false
    }

    // 确认删除
    function confirmDelete(type, name, id) {
        confirmType = type
        confirmName = name
        confirmCallback = function() {
            if (type === "用户") {
                userModel.deleteUser(id, "system")
            } else if (type === "角色") {
                roleModel.deleteRole(id, "system")
            } else if (type === "权限") {
                permissionModel.deletePermission(id, "system")
            }
        }

        var dialog = confirmDialogComponent.createObject(permissionContainer.parent)
        dialog.visible = true
        dialog.x = (permissionContainer.width - dialog.width) / 2
        dialog.y = (permissionContainer.height - dialog.height) / 2
    }

    // 初始化加载
    Component.onCompleted: {
        userModel.loadUsers()
        roleModel.loadRoles()
        permissionModel.loadPermissions()
    }
}