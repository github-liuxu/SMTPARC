# SMTPARC
iOS SMTP协议发送邮件
iOS SMTP协议发送邮件

# iOS SMTP协议发送邮件

最近想做一个发送邮件的程序，所以在网上查了一下，想写个demo出来，后来发现网上有个demo叫SKPSMTP的，但是我发现这个程序最后一次提交代码是7年前也就是说大概是2010年或者2011年写的，还是MRC管理内存，我就下载下来改成了ARC，看了一下他的代码逻辑和处理方式学习一下。
代码在：https://github.com/github-liuxu/SMTPARC

## SMPT协议

SMTP 的全称是“Simple Mail Transfer Protocol”，即简单邮件传输协议。它是一组用于从源地址到目的地址传输邮件的规范，通过它来控制邮件的中转方式。SMTP 协议属于 TCP/IP 协议簇，它帮助每台计算机在发送或中转信件时找到下一个目的地。SMTP 服务器就是遵循 SMTP 协议的发送邮件服务器。 
　　SMTP 认证，简单地说就是要求必须在提供了账户名和密码之后才可以登录 SMTP 服务器，这就使得那些垃圾邮件的散播者无可乘之机。 
　　增加 SMTP 认证的目的是为了使用户避免受到垃圾邮件的侵扰。
　　来自http://help.163.com/09/1223/14/5R7P6CJ600753VB8.html

**SMTP的连接和发送过程**

（a）建立TCP连接

　　windows可以使用telnet smtp.163.com 25 
  
　　mac可以使用nc smtp.163.com 25
  
（b）客户端发送HELO(EHLO)命令以标识发件人自己的身份，然后客户端发送MAIL命令；

　　HELO 163.com
  
　　服务器端正希望以OK作为响应，表明准备接收
  
（c）登录

　　auth login
  
　　服务端返回信息后，输入用户名和密码需要用base64加密输入
  
（d）客户端发送MAIL和RCPT命令，以标识该电子邮件的发件人和接收人，可以有多个RCPT行；

　　mail from:<xxxxxx@163.com>
  
　　rcpt to:<xxxxxx@cdv.com>
  
         服务器端则表示是否愿意为收件人接收邮件
         
（e）协商结束，发送邮件，用命令DATA发送

（f）收件人和发件人和主题要写，不然会被当成垃圾邮件

　　From:xxxxxx@163.com
  
　　To:xxxxxxxx@cdv.com
  
　　Subject:first class
  
　　正文内容
  
（g）以.表示结束输入内容一起发送出去

（h）结束此次发送，用QUIT命令退出

**以下是我的测试**
![在这里插入图片描述](https://img-blog.csdnimg.cn/2018102823335568.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpdXh1bGR4,size_27,color_FFFFFF,t_70)
## 关键代码分析
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181028234348163.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpdXh1bGR4,size_27,color_FFFFFF,t_70)
通过socket创建输入流和输出流
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181028234655853.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpdXh1bGR4,size_27,color_FFFFFF,t_70)
给输入输出流设置代理打开流在回调中读取数据和写入数据
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181028235144137.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpdXh1bGR4,size_27,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181028235557245.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpdXh1bGR4,size_27,color_FFFFFF,t_70)
通过NSScanner读取服务器返回的数据，它每次读了1024个字符不知道服务器返回的多的话会怎么样？估计读不全吧！
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181029000413724.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpdXh1bGR4,size_27,color_FFFFFF,t_70)
以登录为例，写数据的时候将拼好的数据放入写函数中，登录需要将数据base64加密，发送的正文不需要加密
![在这里插入图片描述](https://img-blog.csdnimg.cn/20181028235308289.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpdXh1bGR4,size_27,color_FFFFFF,t_70)
写数据的时候可以给定一个大小，内部做循环写入，直到写入完成。写入前要做判断，有可能此时流还没有被打开。
在做MRC到ARC的过程中有个细节，转换完成的时候我做了一个内存测试，发现内存泄漏，在这一行   [NSStream getStreamsToHostNamed:_relayHost port:relayPort inputStream:&inputStream1 outputStream:&outputStream1];
印象中好像是说我的流没有释放，我查看了一下我该释放的释放了，该桥接的桥接了，怎么会泄漏呢，后在在网上查了一下，还真有人搜索这个问题，但是页面打开不对了，我就点了一下百度快照，这玩意还真行，竟然能看，但是它回答的
它回答的不是一个原因：
host = CFHostCreateWithName(NULL, (__bridge_retained CFStringRef) hostName);
You should use a __bridge cast, not a __bridge_retained cast.
但是有个细节我留意了一下就是它用的都是__bridge_transfer，我就查了一下__bridge_transfer，__bridge，__bridge_retained，的区别：
以下代码来自：https://www.jianshu.com/p/11c3bc21f56e
1.__bridge
CF和OC对象转化时只涉及对象类型不涉及对象所有权的转化
```javascript
//Image I/O 从 NSBundle 读取图片数据
   NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"];
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"]], NULL);
```
如果上面不添加__bridge ，在ARC环境下，系统会给出错误提示和错误修正，点击错误提示的话，系统会为我们自动添加__bridge ，因为在OC与CF的转化时只涉及到对象类型没有涉及到对象所有权的转化，所以上述代码不需要对CF的对象进行释放，即不需要添加CFRelease
为了解决这一问题，我们使用 __bridge 关键字来实现id类型与void*类型的相互转换。
```javascript
 id obj = [[NSObject alloc] init];
    void *p = (__bridge void *)(obj);
    NSLog(@"obj retainCount %ld",[(id)p retainCount]);
```
输出结果
```javascript
CFDemo[2932:777997] obj retainCount 1
```
2.__bridge_transfer
常用在CF对象转化成OC对象时，将CF对象的所有权交给OC对象，此时ARC就能自动管理该内存,作用同CFBridgingRelease()

如果非ARC的时候，我们可能需要写下面的代码。
```javascript
// p 变量原先持有对象的所有权
id obj = (id)p;
[obj retain];
[(id)p release];
```
那么ARC有效后，我们可以用下面的代码来替换
```javascript
// p 变量原先持有对象的所有权
id obj = (__bridge_transfer id)p;
```
可以看出来，__bridge_retained 是编译器替我们做了 retain 操作，而 __bridge_transfer 是替我们做了 release。

3.__bridge_retained
与__bridge_transfer 相反，常用在将OC对象转化成CF对象，且OC对象的所有权也交给CF对象来管理，即OC对象转化成CF对象时，涉及到对象类型和对象所有权的转化，作用同CFBridgingRetain()

先来看使用 __bridge_retained 关键字的例子程序：
```javascript
id obj = [[NSObject alloc] init];
void *p = (__bridge_retained void *)obj;
```
此时retainCount 会被加1；
从名字上我们应该能理解其意义：类型被转换时，其对象的所有权也将被变换后变量所持有。如果不是ARC代码，类似下面的实现：
```javascript
id obj = [[NSObject alloc] init];
void *p = obj;
[(id)p retain];
```
ARC如何获取retainCount
```javascript
NSLog(@"Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)myObject));
```
来来来举个例子：
```javascript
	NSString *string = [NSString stringWithFormat:@""];
    
    CFStringRef cfString = (__bridge CFStringRef)string;
    
    CFStringRef cfStr = (__bridge_retained CFStringRef)string;
    
    CFRelease(cfString);// 由于Core Foundation的对象不属于ARC的管理范畴，所以需要自己release
    
    CFRelease(cfStr);
```
使用 __bridge_retained 可以通过转换目标处（cfStr）的 retain 处理，来使所有权转移。即使 string 变量被释放，cfString变量也变释放，cfStr 还是可以使用具体的对象。只是有一点，由于Core Foundation的对象不属于ARC的管理范畴，所以需要自己release。
```javascript
CFStringRef cfString= CFURLCreateStringByAddingPercentEscapes( NULL, (__bridge CFStringRef)text, NULL, CFSTR("!*’();:@&=+$,/?%#[]"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString *ocString = (__bridge_transfer CFStringRef)cfString;
```
总结：

Core Foundation 对象类型不在 ARC 管理范畴内
Cocoa Framework::Foundation 对象类型（即一般使用到的Objectie-C对象类型）在 ARC 的管理范畴内
3.__bridge，__bridge_transfer和__bridge_retained 是CF和OC的桥梁
如果不在 ARC 管理范畴内的对象，那么要清楚 release 的责任应该是谁以及各种对象的生命周期是怎么样的
