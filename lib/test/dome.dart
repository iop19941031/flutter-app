import 'package:flutter/material.dart';

class TestListPage extends StatelessWidget {
  final List<String> list = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: createGrid(),
    );
  }

  void callbackFun (int index) {
    print(index);
  }
  CustomAnimateGrid createGrid() {
    return CustomAnimateGrid(
      delegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, //列数，即一行有几个子元素；
        crossAxisSpacing: 8.0, //次轴方向上的空隙间距
        mainAxisSpacing: 8.0, //主轴方向上的空隙间距
        childAspectRatio: 1.0, //子元素的宽高比例
      ),
      padding: EdgeInsets.all(8.0),
      itemCount: list.length,
      itemBuilder: itemBuilder,
      onItemPressed: callbackFun,
      onActionFinished: (indexes) {
        indexes.forEach((index) {
          list.removeAt(index);
        });
        return list.length;
      },
    );
  }

  Widget itemBuilder(BuildContext context, int index) {
    return Material(
      child: Center(
        child: Text(list[index]),
      ),
    );
  }
}

const int Trigger = 1;
const int Cancle = 2;
const int SelectAll = 3;
const int Delete = 4;
const int CurrentState = 5;

typedef OnItemBuild = void Function(Size size);

typedef ResultCallBack = bool Function();

typedef IndexCallBack = void Function(int index);

typedef OnActionFinished = int Function(
    List<int> indexes); // 进行数据清除工作，并返回当前list的length

typedef OnItemSelectedChanged = void Function(
    int index, bool isSelected); // 选中状态回调

class CustomAnimateGrid extends StatefulWidget {
  final SliverGridDelegate delegate;
  final IndexedWidgetBuilder itemBuilder;
  final OnActionFinished onActionFinished;
  final IndexCallBack onItemPressed;
  int itemCount;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController controller;
  final bool primary;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry padding;

  CustomAnimateGrid({
    Key key,
    @required this.delegate,
    @required this.itemCount,
    @required this.itemBuilder,
    @required this.onActionFinished,
    this.onItemPressed,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CustomAnimateGridState();
  }
}

class _CustomAnimateGridState extends State<CustomAnimateGrid>
    with TickerProviderStateMixin {
  final List<int> selectedItems = []; // 被选中的item的index集合
  final List<int> remainsItems = []; // 删除后将会保留的item的index集合

  Size _itemSize;

  StateSetter _deleteSheetState;

  AnimationController _slideController;
  AnimationController _deleteSheetController;
  Animation<Offset> _deleteSheetAnimation;

  int _oldItemCount;

  bool _needToAnimate = false; // 是否需要进行平移动画
  bool _readyToDelete = false; // 是否是删除状态
  bool _singleDelete = false; // 是否是单独删除状态，长按item触发

  bool _canAccept = false; // 长按删除时，是否移动到了指定位置

  @override
  void initState() {
    super.initState();
    _slideController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _deleteSheetController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    _deleteSheetAnimation =
        Tween(begin: Offset(0.0, 1.0), end: Offset(0.0, 0.0)).animate(
            CurvedAnimation(
                parent: _deleteSheetController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    super.dispose();
    _slideController.dispose();
    _deleteSheetController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Stack(
          children: <Widget>[
            GridView.builder(
                gridDelegate: widget.delegate, //一个控制 GridView 中子项布局的委托。
                itemCount: widget.itemCount, //子控件数量
                scrollDirection: widget.scrollDirection, //滚动方向
                reverse: widget.reverse, //组件反向排序
                controller: widget.controller, //滚动控制（滚动监听）
                primary: widget.primary, //滚动控制（滚动监听）
//                 滑动类型设置

// AlwaysScrollableScrollPhysics() 总是可以滑动
// NeverScrollableScrollPhysics禁止滚动
// BouncingScrollPhysics 内容超过一屏 上拉有回弹效果
// ClampingScrollPhysics 包裹内容 不会有回弹
                physics: (widget.physics != null
                    ? widget.physics
                    : BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics())),
                shrinkWrap: widget.shrinkWrap, //默认false   内容适配
                padding: widget.padding, //内边距
                itemBuilder: (context, index) {
                  // 	遍历数返回Widget
                  bool isSelected = selectedItems.contains(index);

                  Animation<Offset> slideAnimation;
                  // 需要动画时，添加一个位移动画
                  if (_needToAnimate) {
                    slideAnimation = createTargetItemSlideAnimation(index);
                  }
                  return _GridItem(
                    index,
                    _readyToDelete,
                    widget.itemBuilder(context, index),
                    onItemSelected,
                    widget.onItemPressed,
                    triggerSingleDelete,
                    cancleSingleDelete,
                    isSelected,
                    slideAnimation,
                    onItemBuild: itemBuildCallBack,
                  );
                }),
            StatefulBuilder(
              builder: (context, state) {
                _deleteSheetState = state;
                return Offstage(
                  offstage: !_singleDelete,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SlideTransition(
                      position: _deleteSheetAnimation,
                      child: DragTarget<int>(onWillAccept: (data) {
                        _canAccept = true;
                        return data != null; // dada不是null的时候,接收该数据。
                      }, onAccept: (data) {
                        doSingleDelete(data);
                      }, onLeave: (data) {
                        _canAccept = false;
                      }, builder: (context, candidateData, rejectedData) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 64.0,
                          child: Material(
                            color: Colors.black54,
                            child: Center(
                              child: Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            )
          ],
        ),
        onWillPop: onBackPressed);
  }

  // 拦截返回按键
  Future<bool> onBackPressed() async {
    if (_readyToDelete) {
      cancleDeleteAction();
      return false;
    }
    return true;
  }

  // 首次触发时，计算item所占空间的大小，用于计算位移动画的位置
  void itemBuildCallBack(Size size) {
    if (_itemSize == null) {
      _itemSize = size;
    }
  }

  // Item选中状态回调 --- 将其从选中item的list中添加或删除
  void onItemSelected(int index, bool isSelected) {
    if (isSelected) {
      selectedItems.add(index);
    } else {
      selectedItems.remove(index);
    }
  }

  // 长按Item触发底部删除条状态回调
  void triggerSingleDelete() {
    _deleteSheetState(() {
      _singleDelete = true;
      _deleteSheetController.forward();
    });
  }

  // 未移动至底部删除条，取消单独删除状态
  bool cancleSingleDelete() {
    // 未移动到指定位置时，隐藏底部删除栏，并刷新item状态 --- 移动到指定位置时，只修改item的状态，不刷新布局
    if (!_canAccept) {
      _deleteSheetController.reverse().whenComplete(() {
        _deleteSheetState(() {
          _canAccept = false;
          _singleDelete = false;
        });
      });
    }
    return _canAccept;
  }

  // 移动至底部删除条，删除item，然后取消状态单独删除状态
  void doSingleDelete(int index) {
    _deleteSheetController.reverse().whenComplete(() {
      _deleteSheetState(() {
        _canAccept = false;
        _singleDelete = false;
        selectedItems.add(index);
      });
      doDeleteAction();
    });
  }

  // 取消删除状态，刷新布局
  void cancleDeleteAction() {
    setState(() {
      _readyToDelete = false;
      selectedItems.clear();
    });
  }

  // 删除Item，执行动画，完成后重绘界面
  void doDeleteAction() {
    _readyToDelete = false;
    if (selectedItems.length == 0 || selectedItems.length == widget.itemCount) {
      // 未选中ite或选中了所有item --- 删除item，然后刷新布局，无动画效果
      setState(() {
        widget.itemCount =
            widget.onActionFinished(selectedItems.reversed.toList());
        selectedItems.clear();
      });
    } else {
      // 选中部分item --- 计算需要动画的item，刷新item布局，加入动画控件，然后统一执行动画，结束后刷新布局
      getRemainsItemsList();
      setState(() {
        _needToAnimate = true;
        widget.itemCount =
            widget.onActionFinished(selectedItems.reversed.toList());
      });
      _slideController.forward().whenComplete(() {
        setState(() {
          _slideController.value = 0.0;
          _needToAnimate = false;
          selectedItems.clear();
          remainsItems.clear();
        });
      });
    }
  }

  // 获取将会保留的item的index集合
  void getRemainsItemsList() {
    _oldItemCount = widget.itemCount;
    for (int i = 0; i < _oldItemCount; i++) {
      if (selectedItems.contains(i)) {
        continue;
      }
      remainsItems.add(i);
    }
  }

  // 创建指定item的位移动画
  Animation<Offset> createTargetItemSlideAnimation(int index) {
    int startIndex = remainsItems[index];
    if (startIndex != index) {
      Tween<Offset> tween = Tween(
          begin: getTargetOffset(remainsItems[index], index),
          end: Offset(0.0, 0.0));
      return tween.animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    }
    return null;
  }

  // 返回动画的位置
  Offset getTargetOffset(int startIndex, int endIndex) {
    SliverGridDelegateWithFixedCrossAxisCount delegate = widget.delegate;
    int horizionalSeparation = (startIndex % delegate.crossAxisCount) -
        (endIndex % delegate.crossAxisCount);
    int verticalSeparation = (startIndex ~/ delegate.crossAxisCount) -
        (endIndex ~/ delegate.crossAxisCount);

    double dx = (delegate.crossAxisSpacing + _itemSize.width) *
        horizionalSeparation /
        _itemSize.width;
    double dy = (delegate.mainAxisSpacing + _itemSize.height) *
        verticalSeparation /
        _itemSize.width;

    return Offset(dx, dy);
  }
}

class _GridItem extends StatefulWidget {
  final int index;

  final bool readyToDelete;

  final Widget child;

  final OnItemSelectedChanged onItemSelectedChanged;

  final IndexCallBack onItemPressed;

  final Function singleDeleteStart;
  final ResultCallBack singleDeleteCancle;

  final Animation<Offset> slideAnimation;

  final OnItemBuild onItemBuild;

  _GridItemState _state;

  bool _isSelected;

  _GridItem(
      this.index,
      this.readyToDelete,
      this.child,
      this.onItemSelectedChanged,
      this.onItemPressed,
      this.singleDeleteStart,
      this.singleDeleteCancle,
      this._isSelected,
      this.slideAnimation,
      {this.onItemBuild});

  @override
  State<StatefulWidget> createState() {
    _state = _GridItemState();
    return _state;
  }
}

class _GridItemState extends State<_GridItem> with TickerProviderStateMixin {
  Size _size;

  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    // 获取当前控件的size属性,当渲染完成之后，自动回调,无需unregist
    WidgetsBinding.instance.addPostFrameCallback(onAfterRender);
  }

  @override
  void didUpdateWidget(_GridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 获取当前控件的size属性,当渲染完成之后，自动回调,无需unregist
    WidgetsBinding.instance.addPostFrameCallback(onAfterRender);
  }

  void onAfterRender(Duration timeStamp) {
    _size = context.size;
    widget.onItemBuild(_size);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: buildItem(context),
      onTap: () {
        // 未触发删除状态时，可以调用传入的点击回调参数
        widget.onItemPressed(widget.index);
      },
    );
  }

  Widget buildItem(BuildContext context) {
    return LongPressDraggable<int>(
      data: widget.index,
      child: (_isDragging
          ? Material(
              color: Colors.transparent,
            )
          : buildItemChild()),
      feedback: StatefulBuilder(builder: (context, state) {
        return SizedBox.fromSize(size: _size, child: widget.child);
      }),
      onDragStarted: () {
        setState(() {
          _isDragging = true;
          widget.singleDeleteStart();
        });
      },
      onDragEnd: (details) {
        if (widget.singleDeleteCancle()) {
          _isDragging = false;
        } else {
          setState(() {
            _isDragging = false;
          });
        }
      },
      onDraggableCanceled: (velocity, offset) {
        setState(() {
          _isDragging = false;
          widget.singleDeleteCancle();
        });
      },
    );
  }

  // 若动画不为空，则添加动画控件
  Widget buildItemChild() {
    if (widget.slideAnimation != null) {
      return SlideTransition(
        position: widget.slideAnimation,
        child: widget.child,
      );
    }
    return widget.child;
  }
}
