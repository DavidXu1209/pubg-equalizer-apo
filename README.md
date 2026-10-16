# PUBG 声音调试：Equalizer APO + ReaComp

适合 Windows 10/11 x64、HyperX 飓风三有线版通过 USB 声卡连接的入门配置。其他耳机也能使用脚本选择设备，但需要重新试听。

作用是缩小“大声”和“小声”的差距：压低突发大声，同时适度抬高较小的声音。它不会识别敌人脚步，也不会把枪声、队友、环境声单独分离。压缩会改变远近听感，所以这份参数是调试起点。

## 先下载这三样

1. 本仓库：右上角 **Code → Download ZIP**，下载后**先完整解压**。三个 `.cmd`、`tools` 和 `presets` 要放在同一套目录里。
2. [Equalizer APO 官方下载页](https://sourceforge.net/projects/equalizerapo/)。本次核对和验证的版本为 **1.4.2 x64**。[固定版本下载](https://sourceforge.net/projects/equalizerapo/files/1.4.2/EqualizerAPO-x64-1.4.2.exe/download)。
3. [ReaPlugs 官方下载页](https://www.reaper.fm/reaplugs/)，选择 **ReaPlugs VST v2.36 64-bit**，安装时保留 ReaComp。它负责动态压缩。

不要只装 APO 而漏掉 ReaComp；预设需要这两部分一起工作。仓库不附带第三方安装包。

## 第一次安装，按这个顺序

1. 接好耳机，Windows 当前输出选择 **耳机（HyperX Cloud III）**。先保持平常舒适的低音量，调试中不要来回改系统音量。
2. 安装 APO，建议保留标准目录 `C:\Program Files\EqualizerAPO`，不要直接安装到用户主目录。自动更新检查属于可选项。
3. 在 **Device Selector / 设备选择器**里，只勾选**播放设备**下的 **HyperX Cloud III 耳机**。不要把同名的麦克风当成播放设备，也不要把所有设备全勾上。
4. 点击确定，让程序进行安装测试。程序可能短暂重启音频服务；如要求重启电脑，保存工作后自行重启。**出现红叉或“拒绝访问”时先排错，不要当作已生效。**
5. 安装 ReaPlugs x64。使用默认位置最省事：`C:\Program Files\VSTPlugins\ReaPlugs\reacomp-standalone.dll`。
6. 双击仓库根目录的 **`Enable-PUBG.cmd`**，在 Windows 管理员提示中选择“是”。连接着唯一一副 Cloud III 时会自动选中；否则脚本列出播放设备，输入耳机对应的序号。
7. 脚本会备份当前 APO 主配置，再写入预设，并把预设限制在选中的播放设备上。第一次尚未绑定 APO 时，它会打开设备选择器、停止写入；完成第 3～4 步后再运行一次。
8. 按下面的方法验证，再进游戏微调。

脚本会替换 APO 当前的主配置，因此原有自定义音效在启用期间会被这份配置替代，原文件保存在本机备份中。选中耳机上的音乐、浏览器和语音聊天也会受到压缩；它不是只对 PUBG 生效。

## 平时用哪个文件

- **`Enable-PUBG.cmd`**：启用这套预设，重复运行会保留第一次启用前的备份。
- **`Disable-PUBG.cmd`**：临时关闭 APO 配置里的处理，方便听原声和进行开关对比；不会卸载 APO，也不会关闭耳机厂商自身的音效。
- **`Restore-Previous.cmd`**：恢复首次启用前的 APO 主配置，保留备份文件。
- **`presets/PUBG-CloudIII.txt`**：可手动导入的 APO 预设。它是配置文件，不是双击执行的程序。

如果启用后手动改过 `config.txt`，管理脚本会拒绝覆盖，避免丢掉新改动；先检查差异，再决定是否手动恢复备份。管理记录和备份位于本机 APO 配置目录中，不会传到 GitHub。

## 想直接拖进软件里

可以把 `presets/PUBG-CloudIII.txt` 拖进 **Equalizer APO Configuration Editor**，或用 **File → Open** 打开它。但**打开一个标签页，不等于把它加入实际音频链路**。

如果不用一键脚本，按这三步操作：

1. 把预设复制到 APO 的 `config` 目录。默认就是 `C:\Program Files\EqualizerAPO\config`。原文件名可保留为 `PUBG-CloudIII.txt`。
2. 先备份 `config.txt`，再编辑主配置，加入 `Include: PUBG-CloudIII.txt`。如果已有其他压缩器，先停用它，避免重复压缩。手动 Include 会作用于当时配置选中的设备；需要限制设备时，在编辑器中先添加 **Device / 设备选择**，选择耳机。
3. 检查插件路径。如果 ReaPlugs 装在别处，用编辑器选择实际的 `reacomp-standalone.dll`。保存后进行下面的开关对比。

想省去路径、备份和设备选择的手动操作，使用 `Enable-PUBG.cmd`。

## 怎么确认生效

1. 官方设备安装测试先通过；只看到勾选和“配置已写入”还不够。
2. 打开 APO 编辑器的实际 `config.txt`，确认它包含 `pubg-cloudiii.txt`，且插件没有加载错误。脚本写入后的实际预设在 APO 的 `config` 目录；修改仓库里的副本不会直接改变当前声音。
3. 在固定的低音量下，播放同一段熟悉的声音，交替运行 Disable 和 Enable。不要同时改变系统或游戏音量，否则无法公平比较。
4. 如果仍难判断，可在**备份之后**，短暂把活动预设前面加上 `Preamp: -20 dB`，确认声音明显降低；随后立即删除这行并保存。只测试降低音量，不要用大幅加音量验证。
5. 进入 PUBG 训练场，比较同一把枪单发、连发、换弹和附近移动声。最好让同学按固定路线跑近、跑远，再检查方向与距离判断。

试听时先只用一套处理。检查并暂时关闭额外的 FxSound、Sonar 压缩、Windows 响度均衡以及不需要的虚拟环绕；记录原值，便于恢复。PUBG 的 HRTF 可以固定在你习惯的状态，先别同时更改多个变量。

## 这份预设的参数

- Threshold / 阈值：**-18 dB**。
- Ratio / 压缩比：**4:1**。
- Attack / 起效时间：**0 ms**；Release / 恢复时间：**80 ms**。
- Knee / 过渡范围：**3 dB**；RMS：**0 ms**，按峰值检测。
- Wet / 处理后输出：**+3 dB**；Dry / 原声混合：**静音**。
- Auto make-up：**关**；Pre-comp / 预读：**0 ms**。
- 不叠加均衡器和虚拟环绕。左右声道由同一个立体声插件处理。

文件里是插件归一化参数，例如 `Release 0.016` 对应 80 ms，**不要把文件数值当成界面上的毫秒或分贝直接修改**。需要调参时，打开实际 `config` 目录中的预设，使用 ReaComp 图形界面修改并保存。

## 只改一个参数，听清楚再改下一个

- **枪声仍太突出**：先把阈值从 -18 调到 -20 dB，对比后再决定；压缩会更频繁，也可能更影响距离感。
- **开枪后脚步像被一起压没了**：同一时刻所有声音都会受到压缩。先提高阈值至 -15 dB 或降低压缩比至 3:1，减少介入。
- **声音有忽大忽小的感觉**：恢复时间先从 80 改到 120 ms 比较；如果小声音恢复太慢，再试 60 ms。
- **整体变吵、环境杂音明显**：把 Wet 从 +3 降到 0 dB，别继续提高总音量。
- **听距离更难、声音不自然**：直接 Disable 对比，必要时 Restore。参数需要适合自己的听觉、游戏音量和连接方式。

## 常见问题

**配置写好了，声音没变化。**

检查 Windows 和游戏是否输出到同一个耳机、APO 是否绑定到了当前 USB 设备、音频增强是否被整项禁用、插件路径是否有效。更换 USB 接口或重装声卡驱动后，设备标识可能改变，需要重新运行 Device Selector 和 Enable。ASIO、WASAPI 独占模式可能绕开系统音效，参见 [APO 官方说明](https://sourceforge.net/p/equalizerapo/wiki/Documentation/)。

**官方测试红叉，提示“Initialize failed / 拒绝访问”。**

先确认 APO 安装在标准程序目录、主配置和插件可被系统音频服务读取，再按官方工具提示重新测试或重启电脑。不要对整个用户目录或 Windows 目录批量放宽权限。本项目脚本不会绕过测试，也不会自动重启电脑。

**设备选择器或编辑器报 Qt platform plugin 错误。**

通过开始菜单启动，或确保快捷方式“起始位置”为 APO 安装目录。仍有错误时，用官方安装包修复安装；不要从其他软件复制 Qt DLL 来混用。

**脚本提示找不到 ReaComp。**

确认装的是 ReaPlugs **64 位**，并保留默认 VST 目录。脚本还会检查 APO 安装目录下的 `VSTPlugins\ReaPlugs` 和 `plugins`；自定义路径可改用手动导入法。

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
