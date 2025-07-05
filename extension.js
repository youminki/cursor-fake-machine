const vscode = require("vscode");
const os = require("os");
const path = require("path");
const fs = require("fs");

function getStoragePath() {
  // 사용자가 설정에서 경로를 지정했는지 확인
  const config = vscode.workspace.getConfiguration("cursorFakeMachine");
  const customPath = config.get("storagePath");

  if (customPath && fs.existsSync(customPath)) {
    return customPath;
  }

  // 지정하지 않았거나 경로가 유효하지 않으면 기본 경로 사용
  const platform = os.platform();
  let basePath;

  switch (platform) {
    case "win32":
      basePath = path.join(
        os.homedir(),
        "AppData",
        "Roaming",
        "Cursor",
        "User",
        "globalStorage"
      );
      break;
    case "darwin":
      basePath = path.join(
        os.homedir(),
        "Library",
        "Application Support",
        "Cursor",
        "User",
        "globalStorage"
      );
      break;
    case "linux":
      basePath = path.join(
        os.homedir(),
        ".config",
        "Cursor",
        "User",
        "globalStorage"
      );
      break;
    default:
      throw new Error("지원하지 않는 운영체제입니다.");
  }

  return path.join(basePath, "storage.json");
}

function modifyMacMachineId() {
  try {
    const storagePath = getStoragePath();

    if (!fs.existsSync(storagePath)) {
      throw new Error(`파일이 존재하지 않습니다: ${storagePath}`);
    }

    let data = JSON.parse(fs.readFileSync(storagePath, "utf8"));

    const config = vscode.workspace.getConfiguration("cursorFakeMachine");
    const customMachineId = config.get("customMachineId");
    const newMachineId = customMachineId || generateRandomMachineId();

    data["telemetry.macMachineId"] = newMachineId;

    fs.writeFileSync(storagePath, JSON.stringify(data, null, 2), "utf8");

    return {
      success: true,
      message: "telemetry.macMachineId 값을 성공적으로 수정했습니다.",
      newId: newMachineId,
      path: storagePath,
    };
  } catch (error) {
    throw new Error(`수정 실패: ${error.message}`);
  }
}

function generateRandomMachineId() {
  return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function (c) {
    const r = (Math.random() * 16) | 0;
    const v = c === "x" ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
}

async function killCursorProcesses() {
  const platform = os.platform();
  const exec = require("child_process").exec;

  return new Promise((resolve, reject) => {
    let command = "";
    switch (platform) {
      case "win32":
        command = 'taskkill /F /IM "Cursor.exe"';
        break;
      case "darwin":
        command = "pkill -9 Cursor";
        break;
      case "linux":
        command = "pkill -9 cursor";
        break;
      default:
        reject(new Error("지원하지 않는 운영체제입니다."));
        return;
    }

    exec(command, (error) => {
      if (error && error.code !== 1) {
        reject(error);
      } else {
        resolve();
      }
    });
  });
}

function activate(context) {
  let disposable = vscode.commands.registerCommand(
    "cursor-fake-machine.cursor-fake-machine",
    async function () {
      try {
        const result = modifyMacMachineId();

        vscode.window.showInformationMessage(
          `✅ 수정 성공!\n경로: ${result.path}\n새 machineId: ${result.newId}`
        );

        const answer = await vscode.window.showWarningMessage(
          "Cursor를 재시작하여 변경 사항을 적용할까요?",
          { modal: true },
          "예",
          "아니오"
        );

        if (answer === "예") {
          try {
            await killCursorProcesses();
          } catch (error) {
            vscode.window.showErrorMessage(`재시작 실패: ${error.message}`);
          }
        }
      } catch (error) {
        vscode.window.showErrorMessage(`❌ 수정 실패: ${error.message}`);

        if (error.message.includes("존재하지 않습니다")) {
          const answer = await vscode.window.showInformationMessage(
            "storage.json 경로를 설정하시겠습니까?",
            "예",
            "아니오"
          );
          if (answer === "예") {
            vscode.commands.executeCommand(
              "workbench.action.openSettings",
              "cursorFakeMachine.storagePath"
            );
          }
        }
      }
    }
  );

  context.subscriptions.push(disposable);
}

function deactivate() {}

module.exports = {
  activate,
  deactivate,
};
