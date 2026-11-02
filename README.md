# PUBG 声音调试：Equalizer APO + ReaComp

适合 Windows 10/11 x64、HyperX 飓风三有线版通过 USB 声卡连接的入门配置。其他耳机也能使用脚本选择设备，但需要重新试听。

作用是缩小“大声”和“小声”的差距：压低突发大声，同时适度抬高较小的声音。它不会识别敌人脚步，也不会把枪声、队友、环境声单独分离。压缩会改变远近听感，所以这份参数是调试起点。

## 从零安装：先看完整顺序

**下载并解压项目 → 接好耳机 → 安装 APO → 绑定耳机播放设备 → 安装 ReaPlugs x64 → 运行 Enable → 验证声音处理 → 进训练场试听。**

本项目包含教程、预设和配置管理脚本；Equalizer APO 与 ReaPlugs 需要另外从官网安装，仓库不附带第三方安装包。以下步骤不需要编程，也不要求额外安装 Python、Node 或 Peace。

## 一、下载项目并完整解压

1. 打开 [项目仓库](https://github.com/DavidXu1209/pubg-equalizer-apo)。
2. 点击绿色的 **Code** 按钮，再点击 **Download ZIP**。也可以[直接下载项目 ZIP](https://github.com/DavidXu1209/pubg-equalizer-apo/archive/refs/heads/main.zip)。
3. 下载完成后，右键压缩包，选择“全部解压”。
4. 打开解压后的文件夹，确认至少包含以下文件：

- `Enable-PUBG.cmd`：启用预设。
- `Disable-PUBG.cmd`：临时关闭处理。
- `Restore-Previous.cmd`：恢复原配置。
- `tools` 文件夹。
- `presets` 文件夹。
- `README.md`：本说明。

**整个文件夹一起保留，不要只拿出某一个脚本，也不要直接在压缩包里运行。**项目可以放在自己方便的位置，不要求一定放在 D 盘。

## 二、连接耳机，确认声音输出

1. 先把耳机接到电脑上。飓风三有线版建议按本教程使用随附的 USB 声卡连接。
2. 打开 Windows 声音设置，把输出设备选为实际使用的耳机。
3. 飓风三通常显示为 **耳机（HyperX Cloud III）**；其他型号按实际设备名称选择。
4. 播放一段声音，确认确实从耳机里出来。调试时保持平常舒适的低音量。

## 三、安装 Equalizer APO

官方下载：[Equalizer APO 下载页](https://sourceforge.net/projects/equalizerapo/files/)。本项目使用过的版本为 **EqualizerAPO-x64-1.4.2.exe**，也可使用[固定版本下载链接](https://sourceforge.net/projects/equalizerapo/files/1.4.2/EqualizerAPO-x64-1.4.2.exe/download)。

1. 双击安装程序。
2. Windows 弹出管理员授权时，选择“是”。
3. 按向导点击 **Next / 下一步**，接受许可协议。
4. 安装位置保留默认值：`C:\Program Files\EqualizerAPO`。
5. 继续安装。

**不要把安装位置直接改成桌面或用户主目录。**自动更新检查属于可选项。

安装过程中通常会打开 **Device Selector / 设备选择器**。如果没有打开，可以安装完成后从开始菜单打开。

## 四、在 APO 中选择耳机

在设备选择器里找到 **Playback devices / 播放设备**，然后：

1. 找到实际使用的耳机。
2. 在耳机前面勾选。
3. 点击 **OK / 确定**。
4. 等待程序应用设置和进行安装检查。

飓风三请选择播放设备中的 **HyperX Cloud III**。同一副耳机可能同时出现在播放设备和录音设备中，本教程选择的是**播放设备中的耳机**，不要选成麦克风，也不要把所有设备全部勾上。

程序可能短暂重启音频服务，期间声音会中断。如果要求重启电脑，先保存工作，再重启。

**出现红叉、安装失败或“Initialize failed”时，先排错，不能直接当作已经生效。**

## 五、安装 ReaPlugs 64 位插件

官方下载：[ReaPlugs 官方下载页](https://www.reaper.fm/reaplugs/)。进入页面后，找到并下载 **ReaPlugs VST v2.36 64-bit**。

**页面上方的 REAPER 完整版不是这一步需要下载的软件。**

1. 双击 ReaPlugs 安装程序，按向导接受许可协议。
2. 选择组件时，确保包含 **ReaComp**，它负责动态压缩。
3. 使用默认安装位置，完成安装。
4. 安装后应能找到：`C:\Program Files\VSTPlugins\ReaPlugs\reacomp-standalone.dll`。

**一定要安装 64 位版本。**脚本会检查插件位数，32 位插件不能直接用于这套配置。只装 APO、漏装 ReaComp，预设也无法正常工作。

## 六、运行一键启用脚本

回到第一步解压的项目文件夹：

1. 双击 **`Enable-PUBG.cmd`**。
2. 弹出管理员授权时，选择“是”。
3. 等待脚本检查 APO、ReaComp 和耳机设备。
4. 如果电脑里只有一个名称为 **HyperX Cloud III** 的活动播放设备，脚本会自动选中它；否则会列出设备编号，输入自己耳机对应的编号，再按回车。
5. 出现 **`Preset written`**，表示预设已经写入。脚本也会显示原配置的备份位置，可以记下来，然后按回车关闭窗口。

**脚本不会替你更改 Windows 默认输出设备，所以系统和游戏都要使用刚才选中的耳机。**

启用会替换 APO 当前的主配置，原有自定义音效在启用期间会被这份配置替代，原文件会被备份。新的预设限制在选中的播放设备上；该耳机上的音乐、浏览器和语音聊天也会受到压缩，不仅影响 PUBG。

### 如果提示 First-time setup

如果脚本打开了设备选择器，同时提示 **`ERROR: First-time setup…`**，说明耳机还没有完成 APO 绑定，此时 PUBG 预设还没有写入。

1. 在设备选择器中勾选对应的耳机播放设备。
2. 点击确定并完成检查。
3. 如果要求重启，先重启。
4. **重新运行一次 `Enable-PUBG.cmd`。**

## 七、确认声音处理真正生效

**“配置已写入”不等于“音频处理已经生效”。**

1. 确认官方设备安装检查通过。
2. 确认 Windows 和 PUBG 输出到同一副耳机。
3. 固定较低的系统音量和播放内容，先运行 `Disable-PUBG.cmd` 听一遍。
4. 再运行 `Enable-PUBG.cmd`，听同一段内容做比较。比较期间不要同时改变系统音量或游戏音量。

还可以打开 **Equalizer APO Configuration Editor / 配置编辑器**，查看实际的 `C:\Program Files\EqualizerAPO\config\config.txt`。启用后，主配置中应包含 `Include: pubg-cloudiii.txt`，且 ReaComp 没有加载错误。

脚本写入后的实际预设在 APO 的 `config` 目录。修改仓库里的副本不会直接改变当前声音；**只在编辑器里打开预设文件的新标签页，也不代表预设已经启用**。新手直接使用项目的一键脚本即可。

如果完全没有变化，还需要检查耳机属性中的音频增强通路是否被整项禁用，这可能导致 APO 无法生效，参见 [APO 官方排错说明](https://sourceforge.net/p/equalizerapo/wiki/Documentation/)。

## 八、进 PUBG 训练场试听

先固定音量，使用同一把枪，对比：

- 单发和连续开枪。
- 换弹声。
- 附近人物移动声。
- 不同方向、不同距离的脚步。

有条件可以让同学沿固定路线跑近、跑远，检查方向和距离判断。

试听时先只保留一套处理。暂时停用额外的 FxSound、Sonar 压缩、Windows 响度均衡及不需要的虚拟环绕，并记录原来的设置。PUBG 的 HRTF 可以固定在自己习惯的状态，先别同时更改多个变量；不要把 Windows 音频增强通路整项关掉。

**不同耳机、系统音量和游戏音量，效果都会不同。这份预设是调试起点，游戏内听感需要自己验收。**

## 九、三个脚本分别什么时候用

### Enable-PUBG.cmd：启用

启用这套压缩预设。第一次接管时会备份原来的 APO 主配置；连续启用、关闭、再启用期间，会保留这份最初的备份，不会每次覆盖。

**每次运行 Enable，都会重新载入项目中 `presets/PUBG-CloudIII.txt` 的参数。**如果手动修改过 APO 配置目录里的 `pubg-cloudiii.txt`，先另存备份，避免再次启用时被模板覆盖。

### Disable-PUBG.cmd：临时关闭

让 APO 当前配置暂时不进行处理，适合对比声音，或者平时不想使用这套效果时运行。

**它不会恢复以前的 EQ 设置，也不会关闭耳机厂商自己的音效。**

### Restore-Previous.cmd：恢复原配置

恢复首次启用这套预设之前的 APO 主配置，适合想回到原来设置的时候使用。它不会卸载 APO 或 ReaPlugs，也不会删除备份。恢复后再次启用，才会开始新的备份周期。

这套处理不会随着 PUBG 关闭而自动停用，平时不需要时可以运行 Disable。

如果手动删除或修改主配置，使管理脚本无法确认该文件仍由它管理，脚本会拒绝覆盖。先检查改动，保留配置目录中的 `pubg-backups` 和 `.pubg-apo-state.json`。备份和管理记录只保存在本机，不会上传到 GitHub。

## 进阶：手动导入预设

以下是不用一键脚本时的替代方式；已经按前文启用的用户不需要重复导入，以免叠加压缩。

1. 把 `presets/PUBG-CloudIII.txt` 复制到 APO 的 `config` 目录，默认是 `C:\Program Files\EqualizerAPO\config`。
2. 先备份 `config.txt`，再编辑主配置，加入 `Include: PUBG-CloudIII.txt`。如果已有其他压缩器，先停用它，避免重复处理。手动 Include 会作用于当时配置选中的设备；需要限制设备时，在编辑器中先添加 **Device / 设备选择**，选择耳机。
3. 检查插件路径。如果 ReaPlugs 装在别处，用编辑器选择实际的 `reacomp-standalone.dll`。
4. 保存后，用编辑器中对应处理项的开关，对同一段声音进行比较。手动配置未交给脚本管理时，不要用 Disable / Restore 管理它。

可以将预设拖进配置编辑器或使用 **File → Open** 打开，但还需要把它加入实际主配置才能启用。想省去路径、备份和设备选择的手动操作，使用 `Enable-PUBG.cmd`。

## 这份预设的参数

- Threshold / 阈值：**-18 dB**。
- Ratio / 压缩比：**4:1**。
- Attack / 起效时间：**0 ms**；Release / 恢复时间：**80 ms**。
- Knee / 过渡范围：**3 dB**；RMS：**0 ms**，按峰值检测。
- Wet / 处理后输出：**+3 dB**；Dry / 原声混合：**静音**。
- Auto make-up：**关**；Pre-comp / 预读：**0 ms**。
- 不叠加均衡器和虚拟环绕。左右声道由同一个立体声插件处理。

文件里是插件归一化参数，例如 `Release 0.016` 对应 80 ms，**不要把文件数值当成界面上的毫秒或分贝直接修改**。需要调参时，打开实际 `config` 目录中的预设，使用 ReaComp 图形界面修改并保存。

**调参后的开关对比，请使用编辑器中对应处理项的开关，不要重新运行 Enable；否则会重新载入项目模板。**确认调整后先另存实际预设备份。若要让以后的一键启用继续使用自己的参数，再将确认好的预设同步到本地项目的 `presets/PUBG-CloudIII.txt` 副本中。

## 只改一个参数，听清楚再改下一个

- **枪声仍太突出**：先把阈值从 -18 调到 -20 dB，对比后再决定；压缩会更频繁，也可能更影响距离感。
- **开枪后脚步像被一起压没了**：同一时刻所有声音都会受到压缩。先提高阈值至 -15 dB 或降低压缩比至 3:1，减少介入。
- **声音有忽大忽小的感觉**：恢复时间先从 80 改到 120 ms 比较；如果小声音恢复太慢，再试 60 ms。
- **整体变吵、环境杂音明显**：把 Wet 从 +3 降到 0 dB，别继续提高总音量。
- **听距离更难、声音不自然**：直接 Disable 对比，必要时 Restore。参数需要适合自己的听觉、游戏音量和连接方式。

## 十、常见问题

**配置写好了，声音没变化。**

检查 Windows 和游戏是否输出到同一个耳机、APO 是否绑定到了当前 USB 设备、音频增强是否被整项禁用、插件路径是否有效。更换 USB 接口或重装声卡驱动后，设备标识可能改变，需要重新运行 Device Selector 和 Enable。ASIO、WASAPI 独占模式可能绕开系统音效，参见 [APO 官方说明](https://sourceforge.net/p/equalizerapo/wiki/Documentation/)。

**官方测试红叉，提示“Initialize failed / 拒绝访问”。**

先确认 APO 安装在标准程序目录、主配置和插件可被系统音频服务读取，再按官方工具提示重新测试或重启电脑。不要对整个用户目录或 Windows 目录批量放宽权限。本项目脚本不会绕过测试，也不会自动重启电脑。

**设备选择器或编辑器报 Qt platform plugin 错误。**

通过开始菜单启动，或确保快捷方式“起始位置”为 APO 安装目录。仍有错误时，用官方安装包修复安装；不要从其他软件复制 Qt DLL 来混用。

**脚本提示找不到 ReaComp。**

确认装的是 ReaPlugs **64 位**，并保留默认 VST 目录。脚本还会检查 APO 安装目录下的 `VSTPlugins\ReaPlugs` 和 `plugins`；自定义路径可改用手动导入法。

**找不到耳机，或选错设备。**

先确认耳机已连接、已启用，再核对 Windows 实际输出。重新运行设备选择器，绑定正确的播放设备后再运行 Enable。脚本不会替你更改系统或游戏的输出设备。

**提示 config.txt 被其他方式修改。**

先停止重复运行脚本，检查自己是否手动改过 APO 主配置。保留备份和管理记录，确认差异后再决定如何恢复，避免丢掉新改动。

**声音不自然、忽大忽小或距离感变差。**

先运行 Disable 做对比。需要回到以前的 APO 配置，就运行 Restore，不要靠不断提高总音量解决。

## 验证范围

截至 2026-10-16：配置管理脚本已验证备份、重复启用、关闭、精确恢复、缺失插件、DLL 位数检查和手动改动保护；ReaComp 参数已通过实际 x64 插件的离线处理测试。本机也已通过低幅度测试音验证：Windows 音频服务在 Cloud III 播放设备上匹配到目标配置，并成功加载 ReaComp，没有加载错误；调试日志开关随后已恢复。

离线测试中，峰值为 -40 dBFS 的 1 kHz 小信号增益约为 +3 dB，峰值为 -6 dBFS 的信号增益约为 -6 dB。输入右声道为左声道的一半时，输出比例仍为一半。另测了突发接近满幅的方波，输出未超过数字满幅。这些是合成信号测试，**不等同于 PUBG 脚步可听距离测试，也不保证所有素材都不失真**。

本预设尚未完成用户在 PUBG 内的听感验收。没有“提高多少米听脚步”之类结论，也不是任何主播已核实的原版参数。

开发者可运行 `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-Configuration.ps1` 检查配置管理逻辑。测试仅使用临时目录，不改本机 APO 配置。

## 官方资料

- [Equalizer APO 项目与下载](https://sourceforge.net/projects/equalizerapo/)
- [安装、配置和排错](https://sourceforge.net/p/equalizerapo/wiki/Documentation/)
- [配置命令参考](https://sourceforge.net/p/equalizerapo/wiki/Configuration%20reference/)
- [ReaPlugs 下载与 ReaComp 功能](https://www.reaper.fm/reaplugs/)

这套配置不新增开机启动程序，不修改游戏文件。APO 通过 Windows 音频服务处理选中设备的声音，关闭编辑器后仍可工作。
