const vscode = require('vscode');

function activate(context) {
    vscode.window.showInformationMessage('Cursor Fake Machine 已启动！');
}

function deactivate() {}

module.exports = {
    activate,
    deactivate,
};
