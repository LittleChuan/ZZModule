#  iOS 模块化

## 0.概念探讨

#### 什么是模块化开发？

**模块（Module）**的意思个人理解为一些相关性较高功能的集合，模块化的本质即是将工程切割成为一个个独立的模块，使其内部业务能够自洽，对外部有方法进行通信。

其实无论是叫组件化还是模块化，都是基于模块的概念对工程进行修整，我认为**组件（Component）**的粒度更小，更加偏向功能性，比如一个可以循环滚动的活动展示Banner。而模块的粒度大，偏向逻辑性，更适合业务集合的表述。

#### 为什么要做模块化？

基于日益复杂的APP开发，APP的页面数都在两位数，所实现的业务数量也不少，大量的代码相互引用造成耦合，对于持续的开发和维护造成了不小的影响。所以业务模块的设计变得尤为重要。模块化的价值在于分治，将庞大的APP代码仓库分而治之。

这里有张模块引用的图。

所以具体有哪些好处呢？以下是我个人认为突出的几大优势：

1. 模块间解耦，每个模块都有明确的职责与边界，简化业务处理的逻辑。举个例子看看：新闻模块和评论模块，当我们将他们分割之后，新闻模块的职责就是获取新闻列表、新闻详情、历史足迹等等，而评论模块的职责是发布评论、管理我的评论。这样我在加载新闻的时候，我可以不关心评论的加载，两部分代码分开管理，尽可能减少代码的复杂度。
2. 模块替换，模块独立之后每个模块可以独立存在，也意味着可以被快速替换，只要有一个满足他对外的通信协议的，就能代替成为新的模块，也就是可以局部重构应用。同时模块也能被多个应用重复使用（当时由于UI风格不同，这种现象比较少）。
3. 在开发层面，因为模块明确了，负责人的职责也就明确了，减少了对其他业务代码的修改也就减少了依赖、冲突的可能性，同时每次编译的代码量减少，可以提升开发效率。

## 1.技术研究

### 1.1 需要解决的问题

1. 服务发现——既然所有的模块都是互相独立的，那么对于整体APP来说需要知道他有哪些模块，提供了哪些功能。

2. 服务调用——对于模块来说，当他需要和其他模块进行通信时，他也需要知道目标模块是否存在，是否提供了他所需的功能。

这两点是我们主要想解决的问题，接下来看看有哪些方案可以解决他们。

### 1.2 通常的实现方式

在iOS里，大部分的实现方式都是通过NSClassFromString、NSSelectorFromString的，这样也都避不开使用字符串来反射的情况。也有通过Protocol的方式来避免HardCode。

#### 1.2.1 url-block

这个方案简单易懂，通过绑定字符串与BLOCK，实现通过字符串执行代码的能力。

我们先来研究一下成熟的代码是怎么实现的。

##### [MGJRouter](https://github.com/meili/MGJRouter)

首先先来看看使用方式。

``` objective-c
// register
[MGJRouter registerURLPattern:@"mgj://foo/bar" toHandler:^(NSDictionary *routerParameters) {
    NSLog(@"routerParameterUserInfo:%@", routerParameters[MGJRouterParameterUserInfo]);
}];

// call
[MGJRouter openURL:@"mgj://foo/bar"];

// with parameters
[MGJRouter openURL:@"mgj://foo/bar" withUserInfo:@{@"user_id": @1900} completion:nil];
```

使用方法十分简单，使用URL调用BLOCK执行，``routes``存储了对应关系，按照路径进行了分级。

``` objective-c
// register
- (void)addURLPattern:(NSString *)URLPattern andHandler:(MGJRouterHandler)handler
{
    NSMutableDictionary *subRoutes = [self addURLPattern:URLPattern];
    if (handler && subRoutes) {
        subRoutes[@"_"] = [handler copy];
    }
}

- (void)addURLPattern:(NSString *)URLPattern andObjectHandler:(MGJRouterObjectHandler)handler
{
    NSMutableDictionary *subRoutes = [self addURLPattern:URLPattern];
    if (handler && subRoutes) {
        subRoutes[@"_"] = [handler copy];
    }
}

- (NSMutableDictionary *)addURLPattern:(NSString *)URLPattern
{
    NSArray *pathComponents = [self pathComponentsFromURL:URLPattern];

    NSMutableDictionary* subRoutes = self.routes;
    
    for (NSString* pathComponent in pathComponents) {
        if (![subRoutes objectForKey:pathComponent]) {
            subRoutes[pathComponent] = [[NSMutableDictionary alloc] init];
        }
        subRoutes = subRoutes[pathComponent];
    }
    return subRoutes;
}
```

以上是简略的观摩了一下``MGJRouter``，看完之后思考一下这个方案：

优点显而易见，简单。仅通过``URL->BLOCK``的映射达到了无依赖的调用。

缺点也很明显，``URL``的设定在编码时并不会给出响应提示，同时参数也需要通过Dictionary传递。这两点在开发过程中会造成不小的麻烦。

#### 1.2.2 target-selector

这个方案是通过获取对象、类，对其发送消息实现。

我们也是先来看一下成熟的实现模式。

##### [CTMediator](https://github.com/casatwy/CTMediator)

简单的描述下，这个方案的核心是

``` objective-c
- (id _Nullable )performTarget:(NSString * _Nullable)targetName action:(NSString * _Nullable)actionName params:(NSDictionary * _Nullable)params shouldCacheTarget:(BOOL)shouldCacheTarget;
```

通过``targetName``生成实例，然后实例执行``actionName``的``SEL``。

所以模块需要提供一个类，作为Target并实现其对外的方法。

``` objective-c
@interface Target_A : NSObject

- (UIViewController *)Action_nativeFetchDetailViewController:(NSDictionary *)params;
- (id)Action_showAlert:(NSDictionary *)params;

@end
```

对这些方法的封装，生成``CTMediator (CTMediatorModuleAActions)``，暴露出组件可以执行的方法

``` objective-c
@interface CTMediator (CTMediatorModuleAActions)

- (UIViewController *)CTMediator_viewControllerForDetail;
- (void)CTMediator_showAlertWithMessage:(NSString *)message cancelAction:(void(^)(NSDictionary *info))cancelAction confirmAction:(void(^)(NSDictionary *info))confirmAction;

@end
```

需要使用该模块时，只需要引用这个分类，然后使用``CTMediator``调用即可。

这个方案解决的第一个方案调用时的两个问题，方法与参数。

同时，这个方案并不需要注册的过程，相比上一个方案在启动与内存消耗上具有一定优势。

但这个方案带来了另一个问题，需要提供一个可被其他模块使用的分类，这个导致了额外的代码量。如果没有这个分类的情况下，直接使用第一个方法，也能达到目的，但是HardCode的问题没有被解决。

#### 1.2.3 protocol

通过协议的形式告知其他模块信息，还是首先研究下

##### [BeeHive](https://github.com/alibaba/BeeHive)

这个方法多了``Module``的概念，用来处理系统事件、通用事件以及自定义事件，这个稍后考虑，我们先来看下模块的注册和调用形式。

据我观察，这个方案的核心是通过协议生成实例，首先需要一个``protocol``，然后注册，

``` objective-c
@protocol HomeServiceProtocol <NSObject, BHServiceProtocol>

- (void)registerViewController:(UIViewController *)vc title:(NSString *)title iconName:(NSString *)iconName;

@end
  
// register
[[BeeHive shareInstance] registerService:@protocol(HomeServiceProtocol) service:[BHViewController class]];

// call
id< HomeServiceProtocol > homeVc = [[BeeHive shareInstance] createService:@protocol(HomeServiceProtocol)];
```

同样有``allServicesDict``存储``protocol``与``Class``的关系

``` objective-c
// register
- (void)registerService:(Protocol *)service implClass:(Class)implClass {
    // 前面是验证环节
    NSString *key = NSStringFromProtocol(service);
    NSString *value = NSStringFromClass(implClass);
    
    if (key.length > 0 && value.length > 0) {
        [self.lock lock];
        [self.allServicesDict addEntriesFromDictionary:@{key:value}];
        [self.lock unlock];
    }
}
// call
- (id)createService:(Protocol *)service withServiceName:(NSString *)serviceName shouldCache:(BOOL)shouldCache {
    // 前面是验证，后面还有是否是单例以及是否缓存，并不是那么简单
    Class implClass = [self serviceImplClass:service];
    return [[implClass alloc] init];
}
```

这个方案也是解决了在调用时各种HardCode的问题，并且是完全避免了字符串的存在（可以通过plist注册服务，这里面也只能是字符串了，至少代码里没有了）。

有映射关系就需要存储的空间，同时使用的``protocol``需要对外可见，这个也需要额外的代码支持。

### 1.3 总结一下

以上是我所了解到可以支持模间调用的实现方案，小小的对比下

| 方案            | 优势                                         |
| --------------- | -------------------------------------------- |
| url-block       | 使用``URL->BLOCK``的方式快捷明了地实现目的   |
| target-selector | 无需注册和额外存储映射关系，解决了字符串问题 |
| protocol        | 减少了额外代码，增加了存储，解决了字符串问题 |

感觉需求的不同，可以选择不同的方案，或者同时使用也是可以的。

### 1.4 其他

#### 1.4.1 系统事件

``BeeHive``的``Module``提供了系统事件，以此让模块可以获取APP的生命周期以及系统事件。

使用``NSNotificationCenter``方式也可以获取系统事件，也是个实现思路吧。

#### 1.4.2 持续集成

目前还是``CocoaPods``使用比较多，我们就来研究下使用``pod``集成模块化的流程。

开发代码还是需要私有仓库，所以需要[私有的Pod仓库](https://guides.cocoapods.org/making/private-cocoapods.html)。

[如何开发一个Pod](https://guides.cocoapods.org/making/making-a-cocoapod.html)也不提了，我们直接来看看怎么连通模块与整个APP项目。

不论是Jenkins、Gitlab Runner、Travis，都可以做到自动打包，接下来是我的方案：

1. 完成一阶段开发后，修改版本号，触发``pushTag``

``` shell
#这个是项目名，直接去了文件夹名
PROJECT_NAME=${PWD##*/}
#获取podspec中的版本号
CURRENT_POD_VERSION=$(cat $PROJECT_NAME.podspec | grep 's.version' | grep -o '[0-9]*\.[0-9]*\.[0-9]*.[0-9]*')

#接下来检查一下是不是已经有这个版本号了，如果有，那就推出了
git fetch -t

if [ -n "$(git tag -l | grep $CURRENT_POD_VERSION)" ]
then 
	echo "No new tag, current tag is $CURRENT_POD_VERSION"
	exit 0
fi

#由于是在runner内部不能直接push tag，就重新clone一份代码打上tag
echo "Push new tag $CURRENT_POD_VERSION"
mkdir tmp
cd tmp

git clone git@gitlab.xxx.com:xxx/xxx/iOS/$PROJECT_NAME.git
cd $PROJECT_NAME

#打上新的tag
git tag $CURRENT_POD_VERSION
git push --tags
```

2. 在``tag``上触发的任务执行``releasePod``发布至仓库

``` shell
PROJECT_NAME=${PWD##*/}

git config --get user.name
git config --get user.email

echo "publish repo $PROJECT_NAME"
pod repo push reponame $PROJECT_NAME.podspec --verbose --allow-warnings 

ret=$?
#这里不判断一下失败了会直接成功
if [ "$ret" -ne "0" ];then
	exit 1
fi
```

3. 执行成功之后更新APP

``` shell
PROJECT_NAME=${PWD##*/}

APP_NAME="target"

APP_PATH="$APP_NAME/Podfile"

# 下载主工程，
if [ ! -d "$APP_NAME" ]; then
  git clone git@gitlab.xxx.com:xxx/xxx/iOS/target.git
fi

#开始找版本号
ORIGIN_POD_VERSION=$(cat $APP_PATH | grep $PROJECT_NAME | grep -o '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*')
CURRENT_POD_VERSION=$(cat $PROJECT_NAME.podspec | grep 's.version' | grep -o '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*')
CURRENT_POD_URL=$(cat $PROJECT_NAME.podspec | grep 's.homepage' | grep -o "'.*'" | sed "s/'//g")

echo "ORIGIN_POD_VALUE: $ORIGIN_POD_VERSION"
echo "NEW_POD_VALUE: $CURRENT_POD_VERSION"

#修改版本号
if [[ $ORIGIN_POD_VALUE ]]; then
	echo "s/$ORIGIN_POD_VALUE/$NEW_POD_VALUE/g"

	sed -i "" "s/$ORIGIN_POD_VALUE/$NEW_POD_VALUE/g" $APP_PATH
else
	sed -i "" "/target 'VSNAPP-Swift' do/ a\\
$NEW_POD_VALUE
" $APP_PATH
fi

COMMIT_LOG="The merge request is from $PROJECT_NAME $ORIGIN_POD_VERSION..$CURRENT_POD_VERSION"

cd $APP_NAME

#git提交
git config --get user.name 
git config --get user.email
git add Podfile
git commit $COMMIT_LOG
git remote -v
git push --set-upstream

```

4.最后APP接受新代码时打包并上传至分发平台

## 2.思考与~~演进~~
