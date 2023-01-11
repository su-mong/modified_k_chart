# 추가한 기능
### infoDialog UI Custom 기능

`KChartWidget`의 optional parameter로 `customInfoDialog`를 추가했다.

- 타입 : `Widget Function(KLineEntity entity, ChartTranslations translations)?`
- 기본값 : `null`
    - 만약 `null`이 들어가 있다면, 기본 Info Dialog가 표시된다.
- 사용법
    
    : 일반 Widget 함수 만들듯이 코드를 작성하면 된다.
    
    - `entity` : 데이터
    - `translations` : 각 데이터 항목의 이름
- 특이사항
    - `materialInfoDialog` option의 영향을 받는다. 즉, `materialInfoDialog`가 `true`로 설정되어 있으면 Custom Info Dialog를 `Material`로 한 번 감싸주고, `false`로 설정되어 있다면 감싸지 않는다.
- 설계상 이유
    1. 함수로 설계한 이유 : **(작성중)**
    2. `customInfoDialog` 함수에 `ChartTranslations translations` 파라미터를 추가한 이유 : **(작성중)**

### infoDialog 표시 위치 추가

`KChartWidget`의 optional parameter로 `infoDialogPosition`을 추가했다.

- 타입 : class `InfoDialogPosition`
    
    : 내부 값으로는 다음의 값들이 있다.
    
    - **`alignment`** : enum `InfoDialogAlignment` 타입으로, Info Dialog의 정렬 위치를 나타낸다.
    (기본값 : `InfoDialogAlignment.BothSideTop`)
        - LeftTop : 왼쪽 위에 고정
        - LeftCenter : 왼쪽 가운데 고정
        - LeftBottom : 왼쪽 아래 고정 (Main Chart 아래쪽에 고정됨)
        - RightTop : 오른쪽 위에 고정
        - RightCenter : 오른쪽 가운데 고정
        - RightBottom : 오른쪽 아래 고정 (Main Chart 아래쪽에 고정됨)
        - BothSideTop : 선택한 막대의 위치에 따라, 왼쪽 위나 오른쪽 위에 표시함.
        - BothSideCenter : 선택한 막대의 위치에 따라, 왼쪽 가운데나 오른쪽 가운데에 표시함.
        - BothSideBottom : 선택한 막대의 위치에 따라, 왼쪽 아래나 오른쪽 아래에 표시함.
        (Main Chart 아래쪽에 고정됨)
        - BesideVerticalLineTop : 선택한 막대의 위치에 따라, 막대 양 옆 왼쪽 위나 오른쪽 위에 표시함.
        - BesideVerticalLineCenter : 선택한 막대의 위치에 따라, 막대 양 옆 왼쪽 가운데나 오른쪽 가운데에 표시함.
        - BesideVerticalLineBottom : 선택한 막대의 위치에 따라, 막대 양 옆 왼쪽 아래나 오른쪽 아래에 표시함. (Main Chart 아래쪽에 고정됨)
    - **`top`** : `double` 타입. Main Chart 위쪽 Side에서 Info Dialog 위쪽 Side까지의 간격이다.
    (기본값 : 0)
    - **`bottom`** : `double` 타입. Main Chart 아래쪽 Side에서 Info Dialog 아래쪽 Side까지의 간격이다.
    (기본값 : 0)
    - **`left`** : `double` 타입. ‘왼쪽 Side’에서 Info Dialog 왼쪽 Side까지의 간격이다. (기본값 : 0)
    이 때, ‘왼쪽 Side’에 해당하는 건 `alignment`에 따라 다르다.
        - BesideVerticalLine~ : 선택한 막대를 표시하는 세로선의 왼쪽
        - 나머지 : Main Chart 맨 왼쪽
    - **`right`** : `double` 타입. ‘오른쪽 Side’에서 Info Dialog 오른쪽 Side까지의 간격이다. (기본값 : 0)
    이 때, ‘오른쪽 Side’에 해당하는 건 `alignment`에 따라 다르다.
        - BesideVerticalLine~ : 선택한 막대를 표시하는 세로선의 오른쪽
        - 나머지 : Main Chart 맨 오른쪽

- 고민 : 처음에는 정렬 방향을 지정하는 `InfoDialogAlignment` + Info Dialog의 margin 값인 `EdgeInsets` 의 조합으로 구현하고자 했다.
    
    [생각의 흐름]
    
    1. 이게 직관적인 구현일까? 직관성이 떨어진다는 느낌이 든다.
    2. 차라리, 그냥 `Positioned`처럼 구현하는 게 더 낫지 않을까?
    3. 근데 `Positioned`처럼 구현해 놓으면 Alignment를 따로 지정할 수 있나?
    4. 잠만. 그냥 `InfoDialogAlignment`와 position 숫자값을 포함한 객체를 하나 파면 되겠네!
    5. 근데 이게 더 직관적일까? Ximya 의견은 어떨까? ⇒ Ximya도 4번 방식이 더 Flutter스럽다고 생각하심. (`Positioned`와 비슷하기 때문)

### Volume chart 색상을 main chart의 색상과 분리해서 사용하는 기능

`ChartColors`에서 `volBarColor` 속성을 변경하면 됩니다.

(만약 `volBarColor` 속성을 변경하지 않을 경우, Volume chart의 막대 색상은 원래 데이터가 상승 중이면 `upColor`, 아니라면 `dnColor`를 사용합니다.)

### Volume chart의 라인 표시 선택 기능

우선 `VolState`를 추가했다. Volume Chart의 타입을 나타내는 것으로, `MainState`, `SecondaryState`와 비슷한 역할을 한다.

- ALL : Volume Chart와 MA5 Line Chart, MA10 Line Chart 모두를 표시한다.
- MA5 : Volume Chart와 MA5 Line Chart를 표시한다.
- MA10 : Volume Chart와 MA10 Line Chart를 표시한다.
- NONE : Volume Chart만 표시한다.

그리고, `KChartWidget`의 optional parameter로 `volState`를 추가했다. 기본값은 `VolState.ALL`이기 때문에 모든 차트를 다 표시한다.

추가로, Volume Chart에서는 기본적으로 Volume, MA5, MA10 값을 텍스트로 표시하도록 되어 있는데, 여기에 대해서도 `KChartWidget`에 optional parameter를 추가했다. `volTextHidden`이란 값으로, 기본값은 `false`이기 때문에 모든 텍스트를 보여준다. 만약 이 값이 `true`라면, 텍스트를 표시하지 않는다.

### 날짜 표시 선택 기능

`KChartWidget`의 optional parameter로 `dateTextHidden`를 추가했다.

- 타입 : `bool`
- 기본값 : `false`
- 특징 : `dateTextHidden`이 `true`라면, 차트 맨 아래쪽의 날짜 텍스트가 사라짐과 동시에, 날짜 영역 자체가 사라진다. (즉, 텍스트 색상을 `Colors.transparent`로 설정한 것과 차이가 있다. 텍스트 색상만 바꿀 경우 텍스트 영역 자체는 남아 있기 때문.)

### 선택한 봉의 현재가 / 날짜 표시 선택 기능

1. 선택한 봉의 현재가(가로축 맨 끝에 표시됨) 표시 선택 기능
    
    : `ChartStyle`의 optional parameter로 `showSelectedBarCurrentPrice`를 추가했다.
    (기본값 : `true`)
    
2. 선택한 봉의 날짜(세로축 맨 아래에 표시됨) 표시 선택 기능
    
    : `ChartStyle`의 optional parameter로 `showSelectedBarDate`를 추가했다.
    (기본값 : `true`)
    

### 차트의 봉 라운딩 처리

`ChartStyle`에서 아래 값들을 변경하면 됩니다.

- `candleBodyRadius` : 메인 차트의 real body(시가-종가를 표시하는 사각형)의 radius
- `candleWickRadius` : 메인 차트의 wick(최고가, 최저가까지 이어지는 선)의 radius
- `volRadius` : Volume 차트 막대의 radius

### 각 차트 높이 옵션

- Main Chart
- Volume Chart
- Secondary Chart

### 차트의 기본 표시 언어 선택 가능 옵션

`KChartWidget`의 optional parameter로 `language`를 추가했다. 

- 타입 : `String?`
- 기본값 : `null`
    - 만약 `null`이 들어가 있는 경우, 차트 언어는 기기의 기본 언어로 설정된다. 
    (단, Deprecated parameter인  `isChinese` 값이 `true`로 따로 설정되어 있는 경우, `language` 값은 무시되고 중국어로 표시된다.)
- 제약조건 : `translations`에 `language`로 설정한 언어에 대한 데이터가 있어야 한다.

---

# k_chart
Maybe this is the best k chart in Flutter.Support drag,scale,long press,fling.And easy to use.

## display

#### image

<img src="https://github.com/mafanwei/k_chart/blob/master/example/images/Screenshot1.jpg" width="375" alt="Screenshot"/>

<img src="https://github.com/mafanwei/k_chart/blob/master/example/images/Screenshot2.jpg" width="375" alt="Screenshot"/>

<img src="https://github.com/mafanwei/k_chart/blob/master/example/images/Screenshot3.jpeg" width="375" alt="Screenshot"/>

#### gif

![demo](https://github.com/mafanwei/k_chart/blob/master/example/images/demo.gif)

![demo](https://github.com/mafanwei/k_chart/blob/master/example/images/demo2.gif)

## Getting Started
#### Install
```
dependencies:
  k_chart: ^0.7.0
```
or use latest：
```
k_chart:
    git:
      url: https://github.com/mafanwei/k_chart
```
#### Usage

**When you change the data, you must call this:**
```dart
DataUtil.calculate(datas); //This function has some optional parameters: n is BOLL N-day closing price. k is BOLL param.
```

use k line chart:
```dart
Container(
              height: 450,
              width: double.infinity,
              child: KChartWidget(
                chartStyle, // Required for styling purposes
                chartColors,// Required for styling purposes
                datas,// Required，Data must be an ordered list，(history=>now)
                isLine: isLine,// Decide whether it is k-line or time-sharing
                mainState: _mainState,// Decide what the main view shows
                secondaryState: _secondaryState,// Decide what the sub view shows
                fixedLength: 2,// Displayed decimal precision
                timeFormat: TimeFormat.YEAR_MONTH_DAY,
                onLoadMore: (bool a) {},// Called when the data scrolls to the end. When a is true, it means the user is pulled to the end of the right side of the data. When a
                // is false, it means the user is pulled to the end of the left side of the data.
                maDayList: [5,10,20],// Display of MA,This parameter must be equal to DataUtil.calculate‘s maDayList
                translations: kChartTranslations,// Graphic language
                volHidden: false,// hide volume
                showNowPrice: true,// show now price
                isOnDrag: (isDrag){},// true is on Drag.Don't load data while Draging.
                onSecondaryTap:(){},// on secondary rect taped.
                isTrendLine: false, // You can use Trendline by long-pressing and moving your finger after setting true to isTrendLine property. 
                xFrontPadding: 100 // padding in front
              ),
            ),
```
use depth chart:
```dart
DepthChart(_bids, _asks, chartColors) //Note: Datas must be an ordered list，
```

#### Donate

Buy a cup of coffee for the author.

<img src="https://img-blog.csdnimg.cn/20181205161540134.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3F3ZTI1ODc4,size_16,color_FFFFFF,t_70" width="375" alt="alipay"/>
<img src="https://img-blog.csdnimg.cn/20181205162201519.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3F3ZTI1ODc4,size_16,color_FFFFFF,t_70" width="375" alt="wechat"/>

#### Thanks
[gwhcn/flutter_k_chart](https://github.com/gwhcn/flutter_k_chart)

#### Other
Maybe there are some bugs in this k chart,or you want new indicators,you can create a pull request.I will happy to accept it and I hope we can make it better.
