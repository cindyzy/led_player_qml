import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
// LoginPage.qml
// LoginPage.qml


Page {
    signal loginSuccess

    ColumnLayout {
        anchors.centerIn: parent
        TextField { id: username; placeholderText: "admin"; text: "admin"}
        TextField { id: password; echoMode: TextField.Password; placeholderText: "admin123"; text: "admin123" }
        Button {
            text: "登录"
            onClicked: {
                // 调用 BusinessController 的登录方法（已在 main.cpp 中暴露）
                if (userModel.authenticate(username.text, password.text)) {
                    loginSuccess()   // 发射信号
                } else {
                    errorLabel.text = "登录失败"
                }
            }
        }
        Text { id: errorLabel; color: "red" }
    }
}