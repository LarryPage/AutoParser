# AutoParser
自动化Jons数据与Model互相解析 <br>
一个NSObject Category类，only一个方法即可实现 <br>
Josn与model互相转换，涉及到 <br>
Josn与model数据：字典<-->模型 <br>
Model层级嵌套：Model中属性为数组，NSArray中每个元素为另一model（字典数组<-->模型数组） <br>
Josn层级嵌套，Mode对象josn化 <br>

用例： <br>
1.模型定义->属性字典 <br>
2.复杂的字典 -> 模型 (模型的数组属性里面又装着模型) <br>
3.模型 (模型的数组属性里面又装着模型) -> 复杂的字典 <br>
4.模型 (模型的数组属性里面又装着模型) -> json字符串 <br>
5.json文件 -> 模型 (模型的数组属性里面又装着模型)  用于mock <br>
