iOS上的TokenField控件，具有

1. 可自定义token和对应token视图
2. 可通过键盘删除所选token
3. 可添加尾部视图

使用示例

```
let tokenField = YITokenField()
tokenField.placeholder = "请输入"
// tail
tokenField.tailView = importButton
tokenField.tailWidth = 30
tokenField.register(CustomTokenView.self)
tokenField.delegate = self
view.addSubview(tokenField)
// 设置约束或frame
tokenField.appendTokens([CustomToken(text: "123")])
......
// MARK: YITokenFieldDelegate
func tokenFieldShouldReturn(_ tokenField: YITokenField) -> Bool {
    if let text = tokenField.text {
        tokenField.appendTokens([CustomToken(text: text)])
        tokenField.text = nil
    }
    return true
}

func tokenFieldDidChangeHeight(_ tokenField: YITokenField, newHeight: CGFloat) {
    // 更新tokenField高度
}
```
![img](./demo.gif)