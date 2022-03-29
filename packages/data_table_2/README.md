[![Pub Version](https://img.shields.io/pub/v/data_table_2?label=pub.dev&labelColor=333940&logo=flutter)](https://pub.dev/packages/data_table_2) [![GitHub](https://img.shields.io/github/license/maxim-saplin/data_table_2?color=%23007A88&labelColor=333940)](https://github.com/maxim-saplin/data_table_2/blob/main/LICENSE) [![Tests](https://github.com/maxim-saplin/data_table_2/workflows/Dev%20Build/badge.svg)](https://github.com/maxim-saplin/data_table_2/actions) [![Codecov](https://img.shields.io/codecov/c/github/maxim-saplin/data_table_2/nndb?labelColor=333940&logo=codecov&logoColor=white)](https://codecov.io/gh/maxim-saplin/data_table_2)

In-place substitute for Flutter's stock **DataTable** and **PaginatedDataTable** widgets with fixed header/sticky top row and other useful features missing in the originals. **DataTable2** and **PaginatedDataTable2** widgets are based on the sources of Flutter's originals, mimic the API and provide seamless integration.

If you've been using (or considered using) standard Flutter's widgets for displaying tables or data grids and missed the sticky headers (or vertical borders, 'No rows' placeholder, straightforward async data source API etc.) - you've come to the right place. No need to learn yet another API of a new control, just stick to well described DataTable and PaginatedDataTable.

# [LIVE DEMO](https://maxim-saplin.github.io/data_table_2/)

[<img width="866" alt="image" src="https://user-images.githubusercontent.com/7947027/115952188-48c4e600-a4ed-11eb-9ff9-e5b4deaf9580.png">](https://maxim-saplin.github.io/data_table_2/)

\- please check the [example folder](https://github.com/maxim-saplin/data_table_2/tree/main/example) which demos  various features of the widgets as well as contains few screens with original DataTable and PaginatedDataTable widgets for a reference. There's also a [DataGrid Sample](https://maxim-saplin.github.io/flutter_web_spa_sample/canvaskit/) in separate repo which is based on `DataTable2`.

## Extra Features
- Sticky headers and paginator (when using `PaginatedDataTable2`)
- Vertically scrollable main area (with data rows)
  - `autoRowsToHeight` property on PaginatedDataTable2 allows to auto calculate page size depending on how much rows fit the height and makes vertical scrolling unnecessary
- All columns are fixed width, table automatically stretches horizontally, individual column's width is determined as **(Width)/(Number of Columns)**
  - Should you want to adjust sizes of columns, you can replace `DataColumn` definitions with `DataColumn2` (which is a descendant of DataColumn). The class provides `size` property which can be set to one of 3 relative sizes (S, M and L)
  - Width ratios between Small and Medium, Large and Medium columns are defined by `smRatio` and `lmRatio` params
  - You can limit the minimal width of the control and scroll it horizontally if the viewport is narrower (by setting `minWidth` property) which is useful in portrait orientations with multiple columns not fitting the screen
  - You can add bottom margin (by setting `bottomMargin` property) to allow slight over-scroll
  - Fixed width columns are faster than default implementation of DataTable which does 2 passes to determine contents size and justify column widths
- Data rows are wrapped in `Flexible` and `SingleScrollView` widgets to allow widget to fill parent container and be scrollable
  - Vertical scroller is exposed via table's `scrollController` property. See example 'DataTable2 - Scroll-up' which shows 'up' button when scrolling down and allows to jump to the top of the table
  - `PaginatedDataTable2.fit` property controls whether the paginator sticks to the bottom and leaves a gap to data rows above
- There's `DataRow2` alternative to stock `DataRow` which provides row level tap events (including right clicks)
  - `DataRow2.specificRowHeight` allows overriding default height for any row
- `empty` property which allows defining a placeholder widget to be displayed when data source is empty
- `border` allows drawing inner and outer vertical and horizontal borders (e.g. outlining individual cells) - stock widgets only allow drawing horizontal row splitters
- `PaginatorController` allows to externally control `PaginatedDataTable2` state (e.g. switch pages, change page size etc.)
- Experimental `AsynPaginatedDataTable2` widget is built for asynchronous scenarios (such a requesting data from web service) and relies on `AsyncDataTableSource` returning rows in a `Future`


## Usage

1. Add reference to pubspec.yaml.

2. Import:
```dart
import 'package:data_table_2/data_table_2.dart';
```

3. Code:
```dart
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Example without a datasource
class DataTable2SimpleDemo extends StatelessWidget {
  const DataTable2SimpleDemo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          columns: [
            DataColumn2(
              label: Text('Column A'),
              size: ColumnSize.L,
            ),
            DataColumn(
              label: Text('Column B'),
            ),
            DataColumn(
              label: Text('Column C'),
            ),
            DataColumn(
              label: Text('Column D'),
            ),
            DataColumn(
              label: Text('Column NUMBERS'),
              numeric: true,
            ),
          ],
          rows: List<DataRow>.generate(
              100,
              (index) => DataRow(cells: [
                    DataCell(Text('A' * (10 - index % 10))),
                    DataCell(Text('B' * (10 - (index + 5) % 10))),
                    DataCell(Text('C' * (15 - (index + 5) % 10))),
                    DataCell(Text('D' * (15 - (index + 10) % 10))),
                    DataCell(Text(((index + 0.1) * 25.4).toString()))
                  ]))),
    );
  }
}

```
If you're already using the standard widgets you can reference the package and add '2' to the names of stock widgets (making them **DataTable2** or **PaginatedDataTable2**) and that is it. 

##  Know issues/limitations
- All data rows are fixed height, you can't control individual heights of arbitrary rows
- There's no capability to size data table cells to fit contents. Column width's adapt to available width (either to parent width or `minWidth`), data rows width are predefined by constructor params. Content that doesn't fit a cell gets clipped
- Using `border` properties disables row coloring via `DataRow2(color: MaterialStateColor.resolveWith((states) => ...`
- When setting DataRow/DataRow2 color via `color` property to any material color other than transparent hover colors doesn't get applied. I.e. you can't have both striped rows with hovering working by using MaterialStateColor:
      `color: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.hovered)
              ? Colors.blue
              : index % 2 == 0
                  ? Colors.red
                  : Colors.amber)`
- Cell tap events disabling any row level events. If both a row and a cell within that row happen to have tap events, tapping on a cell won't raise any row events
