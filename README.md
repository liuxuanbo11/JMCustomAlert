# JMCustomAlert
自定义的弹框，封装了常用的功能  
类型:  
1. 基本文字类型  
2. 带UITextField的类型  
3. 带UITextView的类型  
4. UITableView列表选择的类型  
5. 只提供弹框载体，弹框中展示的内容自定义的类型  
  
  
因为之前项目的设计中有Logo, 所以顶部加入了Logo选择, 默认是不加  
可自定义主题颜色, 间距等  
列表样式可以通过代理自定义Cell  
支持横版按钮和竖版按钮  
支持键盘弹出上移遮挡的弹框
  
使用: 可在多个项目的通用类库中添加此弹框，通过创建JMCustomAlertConfig的子类来自定义样式

安装: CocoaPods方式: pod "JMCustomAlert"
