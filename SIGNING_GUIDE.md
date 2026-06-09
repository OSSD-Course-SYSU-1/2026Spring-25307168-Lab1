# 鸿蒙应用签名配置指南

## 问题说明
当前警告：`Will skip sign 'hos_hap'. No signingConfigs profile is configured`

这意味着应用没有签名配置，无法安装到设备或虚拟机。

## 解决方案

### 方法1：自动生成签名（推荐）

1. **打开项目结构设置**
   - 在DevEco Studio中，点击菜单栏 `File > Project Structure`
   - 或使用快捷键 `Ctrl + Alt + Shift + S`

2. **配置签名**
   - 在左侧菜单选择 `Project > Signing Configs`
   - 勾选 `Automatically generate signature` 复选框
   - 点击 `Apply` 然后 `OK`

3. **验证配置**
   - 查看build-profile.json5文件，signingConfigs应该被自动填充
   - 确保signingConfigs不为空数组

4. **重新构建**
   - 点击 `Build > Clean Project`
   - 然后点击 `Build > Rebuild Project`
   - 查看Build Output，应该没有签名警告

5. **运行应用**
   - 点击 `Run > Run 'entry'`
   - 应用应该可以正常安装到虚拟机

### 方法2：手动配置签名

如果自动生成失败，可以手动配置：

1. **生成密钥**
   - 点击 `Build > Generate Key and CSR`
   - 选择密钥存储位置
   - 设置密钥别名和密码（密码至少32位）
   - 生成CSR文件

2. **申请证书**
   - 使用CSR文件在华为开发者平台申请证书
   - 下载证书文件

3. **配置签名**
   - 在 `File > Project Structure > Signing Configs` 中
   - 选择刚才生成的密钥和证书
   - 点击 `OK` 保存

## 常见问题

### Q1: 为什么需要签名？
A: 鸿蒙系统要求所有应用必须签名才能安装，这是安全机制。

### Q2: 自动生成签名失败怎么办？
A: 
- 确保DevEco Studio版本是最新的
- 检查网络连接（需要连接华为服务器）
- 尝试手动配置签名

### Q3: 签名密码有什么要求？
A: 
- storePassword和keyPassword至少32位
- 建议使用强密码（包含大小写字母、数字、特殊字符）

### Q4: 签名配置后还是失败？
A: 
- 检查build-profile.json5中的signingConfigs是否正确填充
- 确保密钥文件路径正确
- 重新Clean和Rebuild项目

## 验证签名配置成功

签名配置成功后，build-profile.json5应该类似这样：

```json5
{
  "app": {
    "signingConfigs": [
      {
        "name": "default",
        "type": "HarmonyOS",
        "material": {
          "certpath": "路径/到/证书.cer",
          "storePassword": "至少32位的密码",
          "keyAlias": "密钥别名",
          "keyPassword": "至少32位的密码",
          "profile": "路径/到/配置文件.p7b",
          "signAlg": "SHA256withECDSA",
          "storeFile": "路径/到/密钥库.p12"
        }
      }
    ],
    ...
  }
}
```

## 下一步

配置完签名后：
1. Clean Project
2. Rebuild Project
3. Run 'entry'
4. 应用应该可以正常启动了

如果还有问题，请查看DevEco Studio的Build Output和Log面板获取详细错误信息。
