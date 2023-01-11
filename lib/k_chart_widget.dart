import 'dart:async';

import 'package:flutter/material.dart';
import 'package:k_chart/chart_translations.dart';
import 'package:k_chart/extension/map_ext.dart';
import 'package:k_chart/flutter_k_chart.dart';

enum MainState { MA, BOLL, NONE }

// Volume Chart Type.
//    - ALL : showing Volume Chart + MA5 Line Chart + MA10 Line Chart
//    - MA5 : showing Volume Chart + MA5 Line Chart
//    - MA10 : showing Volume Chart + MA10 Line Chart
//    - NONE : showing Volume Chart only
enum VolState { ALL, MA5, MA10, NONE }

enum SecondaryState { MACD, KDJ, RSI, WR, CCI, NONE }

// InfoDialog Alignment Type.
//    - Left : Show InfoDialog in the upper left corner of Main Chart.
//    - Right : Show InfoDialog in the upper right corner of Main Chart.
//    - BothSide : default. Depending on the location of the selected bar, display InfoDialog in the upper left corner or upper right corner of Main Chart.
//    - BesideVerticalLine : Depending on the location of the selected bar, InfoDialog is displayed in the upper left or upper right of the selected bar.
//    TODO - LeftTop : Show InfoDialog in the upper left corner of Main Chart.
//    TODO - LeftCenter : Show InfoDialog in the center left corner of Main Chart.
//    TODO - LeftBottom : Show InfoDialog in the lower left corner of Main Chart.
//    TODO - RightTop : Show InfoDialog in the upper right corner of Main Chart.
//    TODO - RightCenter : Show InfoDialog in the center right corner of Main Chart.
//    TODO - RightBottom : Show InfoDialog in the lower right corner of Main Chart.
//    TODO - BothSideTop : Depending on the location of the selected bar, display InfoDialog in the upper left corner or upper right corner of Main Chart.
//    TODO - BothSideCenter : Depending on the location of the selected bar, display InfoDialog in the center left corner or center right corner of Main Chart.
//    TODO - BothSideBottom : Depending on the location of the selected bar, display InfoDialog in the lower left corner or lower right corner of Main Chart.
//    TODO - BesideVerticalLineTop : Depending on the location of the selected bar, InfoDialog is displayed in the upper left or upper right of the selected bar.
//    TODO - BesideVerticalLineCenter : Depending on the location of the selected bar, InfoDialog is displayed in the center left or center right of the selected bar.
//    TODO - BesideVerticalLineBottom : Depending on the location of the selected bar, InfoDialog is displayed in the lower left or lower right of the selected bar.
enum InfoDialogAlignment { Left, Right, BothSide, BesideVerticalLine }

class TimeFormat {
  static const List<String> YEAR_MONTH_DAY = [yyyy, '-', mm, '-', dd];
  static const List<String> YEAR_MONTH_DAY_WITH_HOUR = [
    yyyy,
    '-',
    mm,
    '-',
    dd,
    ' ',
    HH,
    ':',
    nn
  ];
}

// This is used to determine the location of InfoDialog.
class InfoDialogPosition {
  // alignment of InfoDialog
  final InfoDialogAlignment alignment;
  // Gap from side above Main Chart to side above InfoDialog or side below Main Chart to side below InfoDialog
  final double vertical;
  // Gap from `the left side` to the left side of InfoDialog or `the right side` to the right side of InfoDialog.
  //    In this case, `the left side`/`the right side` depends on the alignment param.
  //    - If alignment is starts with 'BesideVerticalLine', `the left side`/`the right side` means left/right side of the vertical line that displays the selected bar.
  //    - Else, `the left side`/`the right side` means far left/right side of Main Chart.
  final double horizontal;

  const InfoDialogPosition({
    this.alignment = InfoDialogAlignment.BothSide,
    this.vertical = 25,
    this.horizontal = 4,
  });
}

class KChartWidget extends StatefulWidget {
  final List<KLineEntity>? datas;
  final MainState mainState;
  final VolState volState;
  final bool volHidden;
  final bool volTextHidden; /// whether to hide the text(`VOL:~~~  MA5:~~~  MA10:~~~`) in Volume Chart
  final SecondaryState secondaryState;
  final Function()? onSecondaryTap;
  final bool isLine;
  final bool isTapShowInfoDialog; //是否开启单击显示详情数据
  final bool hideGrid;
  @Deprecated('Use `translations` instead.')
  final bool isChinese;
  final bool showNowPrice;
  final bool dateTextHidden; /// whether to hide date text below chart
  final bool showInfoDialog;
  final bool materialInfoDialog; // Material风格的信息弹窗
  final Widget Function(KLineEntity entity, ChartTranslations translations)? customInfoDialog; /// custom InfoDialog Widget
  final InfoDialogPosition infoDialogPosition; /// the position and alignment of InfoDialog
  final Map<String, ChartTranslations> translations;
  final String? language; /// Select Default Language. If [language] is null, it will use default language settings in device.
  final List<String> timeFormat;

  //当屏幕滚动到尽头会调用，真为拉到屏幕右侧尽头，假为拉到屏幕左侧尽头
  final Function(bool)? onLoadMore;

  final int fixedLength;
  final List<int> maDayList;
  final int flingTime;
  final double flingRatio;
  final Curve flingCurve;
  final Function(bool)? isOnDrag;
  final ChartColors chartColors;
  final ChartStyle chartStyle;
  final VerticalTextAlignment verticalTextAlignment;
  final bool isTrendLine;
  final double xFrontPadding;

  KChartWidget(
      this.datas,
      this.chartStyle,
      this.chartColors, {
        required this.isTrendLine,
        this.xFrontPadding = 100,
        this.mainState = MainState.MA,
        this.secondaryState = SecondaryState.MACD,
        this.onSecondaryTap,
        this.volState = VolState.ALL,
        this.volHidden = false,
        this.volTextHidden = false,
        this.isLine = false,
        this.isTapShowInfoDialog = false,
        this.hideGrid = false,
        @Deprecated('Use `translations` instead.') this.isChinese = false,
        this.showNowPrice = true,
        this.dateTextHidden = false,
        this.showInfoDialog = true,
        this.materialInfoDialog = true,
        this.customInfoDialog,
        this.infoDialogPosition = const InfoDialogPosition(),
        this.translations = kChartTranslations,
        this.language,
        this.timeFormat = TimeFormat.YEAR_MONTH_DAY,
        this.onLoadMore,
        this.fixedLength = 2,
        this.maDayList = const [5, 10, 20],
        this.flingTime = 600,
        this.flingRatio = 0.5,
        this.flingCurve = Curves.decelerate,
        this.isOnDrag,
        this.verticalTextAlignment = VerticalTextAlignment.left,
      });

  @override
  _KChartWidgetState createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget>
    with TickerProviderStateMixin {
  double mScaleX = 1.0, mScrollX = 0.0, mSelectX = 0.0;
  StreamController<InfoWindowEntity?>? mInfoWindowStream;
  double mHeight = 0, mWidth = 0;
  AnimationController? _controller;
  Animation<double>? aniX;

  //For TrendLine
  List<TrendLine> lines = [];
  double? changeinXposition;
  double? changeinYposition;
  double mSelectY = 0.0;
  bool waitingForOtherPairofCords = false;
  bool enableCordRecord = false;

  double getMinScrollX() {
    return mScaleX;
  }

  double _lastScale = 1.0;
  bool isScale = false, isDrag = false, isLongPress = false, isOnTap = false;

  @override
  void initState() {
    super.initState();
    mInfoWindowStream = StreamController<InfoWindowEntity?>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    mInfoWindowStream?.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.datas != null && widget.datas!.isEmpty) {
      mScrollX = mSelectX = 0.0;
      mScaleX = 1.0;
    }
    final _painter = ChartPainter(
      widget.chartStyle,
      widget.chartColors,
      lines: lines, //For TrendLine
      xFrontPadding: widget.xFrontPadding,
      isTrendLine: widget.isTrendLine, //For TrendLine
      selectY: mSelectY, //For TrendLine
      datas: widget.datas,
      scaleX: mScaleX,
      scrollX: mScrollX,
      selectX: mSelectX,
      isLongPass: isLongPress,
      isOnTap: isOnTap,
      isTapShowInfoDialog: widget.isTapShowInfoDialog,
      mainState: widget.mainState,
      /// changed by sumong : add [widget.volState]
      volState: widget.volState,
      volTextHidden: widget.volTextHidden,
      dateTextHidden: widget.dateTextHidden,
      volHidden: widget.volHidden,
      secondaryState: widget.secondaryState,
      isLine: widget.isLine,
      hideGrid: widget.hideGrid,
      showNowPrice: widget.showNowPrice,
      sink: mInfoWindowStream?.sink,
      fixedLength: widget.fixedLength,
      maDayList: widget.maDayList,
      verticalTextAlignment: widget.verticalTextAlignment,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        mHeight = constraints.maxHeight;
        mWidth = constraints.maxWidth;

        return GestureDetector(
          onTapUp: (details) {
            if (!widget.isTrendLine &&
                widget.onSecondaryTap != null &&
                _painter.isInSecondaryRect(details.localPosition)) {
              widget.onSecondaryTap!();
            }

            if (!widget.isTrendLine &&
                _painter.isInMainRect(details.localPosition)) {
              isOnTap = true;
              if (mSelectX != details.localPosition.dx &&
                  widget.isTapShowInfoDialog) {
                mSelectX = details.localPosition.dx;
                notifyChanged();
              }
            }
            if (widget.isTrendLine && !isLongPress && enableCordRecord) {
              enableCordRecord = false;
              Offset p1 = Offset(getTrendLineX(), mSelectY);
              if (!waitingForOtherPairofCords)
                lines.add(TrendLine(
                    p1, Offset(-1, -1), trendLineMax!, trendLineScale!));

              if (waitingForOtherPairofCords) {
                var a = lines.last;
                lines.removeLast();
                lines.add(TrendLine(a.p1, p1, trendLineMax!, trendLineScale!));
                waitingForOtherPairofCords = false;
              } else {
                waitingForOtherPairofCords = true;
              }
              notifyChanged();
            }
          },
          onHorizontalDragDown: (details) {
            isOnTap = false;
            _stopAnimation();
            _onDragChanged(true);
          },
          onHorizontalDragUpdate: (details) {
            if (isScale || isLongPress) return;
            mScrollX = ((details.primaryDelta ?? 0) / mScaleX + mScrollX)
                .clamp(0.0, ChartPainter.maxScrollX)
                .toDouble();
            notifyChanged();
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            var velocity = details.velocity.pixelsPerSecond.dx;
            _onFling(velocity);
          },
          onHorizontalDragCancel: () => _onDragChanged(false),
          onScaleStart: (_) {
            isScale = true;
          },
          onScaleUpdate: (details) {
            if (isDrag || isLongPress) return;
            mScaleX = (_lastScale * details.scale).clamp(0.5, 2.2);
            notifyChanged();
          },
          onScaleEnd: (_) {
            isScale = false;
            _lastScale = mScaleX;
          },
          onLongPressStart: (details) {
            isOnTap = false;
            isLongPress = true;
            if ((mSelectX != details.localPosition.dx ||
                mSelectY != details.globalPosition.dy) &&
                !widget.isTrendLine) {
              mSelectX = details.localPosition.dx;
              notifyChanged();
            }
            //For TrendLine
            if (widget.isTrendLine && changeinXposition == null) {
              mSelectX = changeinXposition = details.localPosition.dx;
              mSelectY = changeinYposition = details.globalPosition.dy;
              notifyChanged();
            }
            //For TrendLine
            if (widget.isTrendLine && changeinXposition != null) {
              changeinXposition = details.localPosition.dx;
              changeinYposition = details.globalPosition.dy;
              notifyChanged();
            }
          },
          onLongPressMoveUpdate: (details) {
            if ((mSelectX != details.localPosition.dx ||
                mSelectY != details.globalPosition.dy) &&
                !widget.isTrendLine) {
              mSelectX = details.localPosition.dx;
              mSelectY = details.localPosition.dy;
              notifyChanged();
            }
            if (widget.isTrendLine) {
              mSelectX =
                  mSelectX + (details.localPosition.dx - changeinXposition!);
              changeinXposition = details.localPosition.dx;
              mSelectY =
                  mSelectY + (details.globalPosition.dy - changeinYposition!);
              changeinYposition = details.globalPosition.dy;
              notifyChanged();
            }
          },
          onLongPressEnd: (details) {
            isLongPress = false;
            enableCordRecord = true;
            mInfoWindowStream?.sink.add(null);
            notifyChanged();
          },
          child: Stack(
            children: <Widget>[
              CustomPaint(
                size: Size(double.infinity, double.infinity),
                painter: _painter,
              ),

              /// if [widget.customInfoDialog] is not null and [widget.showInfoDialog] is true,  build custom InfoDialog
              if (widget.customInfoDialog != null && widget.showInfoDialog)
                _buildCustomInfoDialog(widget.customInfoDialog!)
              /// if [widget.customInfoDialog] is null and [widget.showInfoDialog] is true, build normal InfoDialog
              else if (widget.showInfoDialog)
                _buildInfoDialog()
            ],
          ),
        );
      },
    );
  }

  void _stopAnimation({bool needNotify = true}) {
    if (_controller != null && _controller!.isAnimating) {
      _controller!.stop();
      _onDragChanged(false);
      if (needNotify) {
        notifyChanged();
      }
    }
  }

  void _onDragChanged(bool isOnDrag) {
    isDrag = isOnDrag;
    if (widget.isOnDrag != null) {
      widget.isOnDrag!(isDrag);
    }
  }

  void _onFling(double x) {
    _controller = AnimationController(
        duration: Duration(milliseconds: widget.flingTime), vsync: this);
    aniX = null;
    aniX = Tween<double>(begin: mScrollX, end: x * widget.flingRatio + mScrollX)
        .animate(CurvedAnimation(
        parent: _controller!.view, curve: widget.flingCurve));
    aniX!.addListener(() {
      mScrollX = aniX!.value;
      if (mScrollX <= 0) {
        mScrollX = 0;
        if (widget.onLoadMore != null) {
          widget.onLoadMore!(true);
        }
        _stopAnimation();
      } else if (mScrollX >= ChartPainter.maxScrollX) {
        mScrollX = ChartPainter.maxScrollX;
        if (widget.onLoadMore != null) {
          widget.onLoadMore!(false);
        }
        _stopAnimation();
      }
      notifyChanged();
    });
    aniX!.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _onDragChanged(false);
        notifyChanged();
      }
    });
    _controller!.forward();
  }

  void notifyChanged() => setState(() {});

  late List<String> infos;

  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowEntity?>(
        stream: mInfoWindowStream?.stream,
        builder: (context, snapshot) {
          if ((!isLongPress && !isOnTap) ||
              widget.isLine == true ||
              !snapshot.hasData ||
              snapshot.data?.kLineEntity == null) return Container();
          KLineEntity entity = snapshot.data!.kLineEntity;
          double upDown = entity.change ?? entity.close - entity.open;
          double upDownPercent = entity.ratio ?? (upDown / entity.open) * 100;
          final double? entityAmount = entity.amount;
          infos = [
            getDate(entity.time),
            entity.open.toStringAsFixed(widget.fixedLength),
            entity.high.toStringAsFixed(widget.fixedLength),
            entity.low.toStringAsFixed(widget.fixedLength),
            entity.close.toStringAsFixed(widget.fixedLength),
            "${upDown > 0 ? "+" : ""}${upDown.toStringAsFixed(widget.fixedLength)}",
            "${upDownPercent > 0 ? "+" : ''}${upDownPercent.toStringAsFixed(2)}%",
            if (entityAmount != null) entityAmount.toInt().toString()
          ];

          final dialogPadding = 4.0;
          final dialogWidth = mWidth / 3;

          /// calculate margin by [widget.infoDialogPosition]
          late final EdgeInsets margin;
          switch(widget.infoDialogPosition.alignment) {
            case InfoDialogAlignment.Left:
              margin = EdgeInsets.only(
                left: widget.infoDialogPosition.horizontal,
                top: widget.infoDialogPosition.vertical,
              );
              break;
            case InfoDialogAlignment.Right:
              margin = EdgeInsets.only(
                left: mWidth - dialogWidth - widget.infoDialogPosition.horizontal,
                top: widget.infoDialogPosition.vertical,
              );
              break;
            case InfoDialogAlignment.BothSide:
              margin = EdgeInsets.only(
                left: snapshot.data!.isLeft ? widget.infoDialogPosition.horizontal : mWidth - dialogWidth - widget.infoDialogPosition.horizontal,
                top: widget.infoDialogPosition.vertical,
              );
              break;
            case InfoDialogAlignment.BesideVerticalLine:
              margin = EdgeInsets.only(
                left: snapshot.data!.isLeft
                    ? mSelectX - dialogWidth - widget.chartStyle.vCrossWidth - widget.infoDialogPosition.horizontal
                    : mSelectX + widget.chartStyle.vCrossWidth + widget.infoDialogPosition.horizontal,
                top: widget.infoDialogPosition.vertical,
              );
              break;
          }

          return Container(
            margin: margin,
            width: dialogWidth,
            decoration: BoxDecoration(
                color: widget.chartColors.selectFillColor,
                border: Border.all(
                    color: widget.chartColors.selectBorderColor, width: 0.5)),
            child: ListView.builder(
              padding: EdgeInsets.all(dialogPadding),
              itemCount: infos.length,
              itemExtent: 14.0,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                /// if user sets [language] parameter, then [translations] must have key named [language].
                assert((widget.language == null) ? true : widget.translations.containsKey(widget.language!));

                /// changed by sumong : add option about [widget.language]
                final translations = widget.isChinese
                    ? kChartTranslations['zh_CN']!
                    : widget.language != null
                    ? widget.translations[widget.language!]!
                    : widget.translations.of(context);

                return _buildItem(
                  infos[index],
                  translations.byIndex(index),
                );
              },
            ),
          );
        });
  }

  /// build custom InfoDialog function (using user-defined [customInfoDialog] function)
  Widget _buildCustomInfoDialog(Widget Function(KLineEntity entity, ChartTranslations translations) customInfoDialog) {
    return StreamBuilder<InfoWindowEntity?>(
        stream: mInfoWindowStream?.stream,
        builder: (context, snapshot) {
          final dialogWidth = mWidth / 3;

          if ((!isLongPress && !isOnTap) ||
              widget.isLine == true ||
              !snapshot.hasData ||
              snapshot.data?.kLineEntity == null) return Container();

          KLineEntity entity = snapshot.data!.kLineEntity;

          /// calculate margin by [widget.infoDialogPosition]
          late final EdgeInsets margin;
          switch(widget.infoDialogPosition.alignment) {
            case InfoDialogAlignment.Left:
              margin = EdgeInsets.only(
                left: widget.infoDialogPosition.horizontal,
                top: widget.infoDialogPosition.vertical,
              );
              break;
            case InfoDialogAlignment.Right:
              margin = EdgeInsets.only(
                left: mWidth - dialogWidth - widget.infoDialogPosition.horizontal,
                top: widget.infoDialogPosition.vertical,
              );
              break;
            case InfoDialogAlignment.BothSide:
              margin = EdgeInsets.only(
                left: snapshot.data!.isLeft ? widget.infoDialogPosition.horizontal : mWidth - dialogWidth - widget.infoDialogPosition.horizontal,
                top: widget.infoDialogPosition.vertical,
              );
              break;
            case InfoDialogAlignment.BesideVerticalLine:
              margin = EdgeInsets.only(
                left: snapshot.data!.isLeft
                    ? mSelectX - dialogWidth - widget.chartStyle.vCrossWidth - widget.infoDialogPosition.horizontal
                    : mSelectX + widget.chartStyle.vCrossWidth + widget.infoDialogPosition.horizontal,
                top: widget.infoDialogPosition.vertical,
              );
              break;
          }

          /// if user sets [language] parameter, then [translations] must have key named [language].
          assert((widget.language == null) ? true : widget.translations.containsKey(widget.language!));
          /// add option about [widget.language]
          final translations = widget.isChinese
              ? kChartTranslations['zh_CN']!
              : widget.language != null
              ? widget.translations[widget.language!]!
              : widget.translations.of(context);

          return widget.materialInfoDialog
              ? Material(
            color: Colors.transparent,
            child: Container(
              width: dialogWidth,
              margin: margin,
              child: customInfoDialog(entity, translations),
            ),
          )
              : SizedBox(width: dialogWidth, child: customInfoDialog(entity, translations));
        });
  }

  Widget _buildItem(String info, String infoName) {
    Color color = widget.chartColors.infoWindowNormalColor;
    if (info.startsWith("+"))
      color = widget.chartColors.infoWindowUpColor;
    else if (info.startsWith("-")) color = widget.chartColors.infoWindowDnColor;
    final infoWidget = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: Text("$infoName",
                style: TextStyle(
                    color: widget.chartColors.infoWindowTitleColor,
                    fontSize: 10.0))),
        Text(info, style: TextStyle(color: color, fontSize: 10.0)),
      ],
    );
    return widget.materialInfoDialog
        ? Material(color: Colors.transparent, child: infoWidget)
        : infoWidget;
  }

  String getDate(int? date) => dateFormat(
      DateTime.fromMillisecondsSinceEpoch(
          date ?? DateTime.now().millisecondsSinceEpoch),
      widget.timeFormat);
}
