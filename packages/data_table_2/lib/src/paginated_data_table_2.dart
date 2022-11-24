// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright 2021 Maxim Saplin - chnages and modifications to original Flutter implementation of PaginatedDataTable
import 'dart:async';
import 'dart:math' as math;

import 'package:async/async.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';

import 'data_table_2.dart';

part 'async_paginated_data_table_2.dart';

/// Allows to externally control [PaginatedDataTable2] state
/// and trigger actions such as changing page number or size. Instatiate an object,
/// keep it somewhere (e.g. parent widgets state or static field/top level variable),
/// pass it to [PaginatedDataTable2.controller] via constructor and you're ready to go.
/// Please note that there're a few properties that allow to fetch internal state
/// value's (such as rows per page), those values can't be fetched until the
/// controller is attached - this happens during the first call to the build()
/// method of [PaginatedDataTable2].
/// The controller extends [ChangeNotifier] in order to let consumers know
/// if there're changes to [PaginatedDataTable2] state. E.g. you can hide
/// standard paginator of [PaginatedDataTable2] and simplement your own
/// paginator as a StatefullWidget, subsribe to controller in order to update
/// the paginator.
class PaginatorController extends ChangeNotifier {
  PaginatedDataTable2State? _state;

  // Whenever setState is called within PaginatedDataTable2State and there's
  // an attached controlooer, than this method is called by PaginatedDataTable2State
  void _notifyListeners() {
    notifyListeners();
  }

  /// The controllor is attched to [PaginatedDataTable2] state upon
  /// the first build. Until data from internal stare is not available
  bool get isAttached => _state != null;

  void _attach(PaginatedDataTable2State state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  void _checkAttachedAndThrow() {
    if (_state == null)
      throw 'PaginatorController is not attached to any PaginatedDataTable2 and can\'t be used';
  }

  void _assertIfNotAttached() {
    assert(_state != null,
        'PaginatorController is not attached to any PaginatedDataTable2 and can\'t be used');
  }

  /// Returns number of rows displayed in the [PaginatedDataTable2]. Throws if no
  /// table is attached to the controller
  int get rowCount {
    _checkAttachedAndThrow();
    return _state!._rowCount;
  }

  /// Returns number of rows displayed in single page of the [PaginatedDataTable2].
  /// Throws if no table is attached to the controller
  int get rowsPerPage {
    _checkAttachedAndThrow();
    return _state!._effectiveRowsPerPage;
  }

  /// Returns the index of the first (topmost) row displayed currently displayed in [PaginatedDataTable2].
  /// Throws if no table is attached to the controller
  int get currentRowIndex {
    _checkAttachedAndThrow();
    return _state!._firstRowIndex;
  }

  /// Сhange page size and set the number of rows in a single page
  void setRowsPerPage(int rowsPerPage) {
    _assertIfNotAttached();
    _state?._setRowsPerPage(rowsPerPage);
  }

  /// Show rows from the next page
  void goToNextPage() {
    _assertIfNotAttached();
    if (_state != null) {
      if (_state!._isNextPageUnavailable()) return;
      _state!._handleNext();
    }
  }

  /// Show rows from the previous page
  void goToPreviousPage() {
    _assertIfNotAttached();
    _state?._handlePrevious();
  }

  /// Fast forward to the very first page/row
  void goToFirstPage() {
    _assertIfNotAttached();
    _state?._handleFirst();
  }

  /// Fast forward to the very last page/row
  void goToLastPage() {
    _assertIfNotAttached();
    _state?._handleLast();
  }

  /// Switch the page so that he given row is displayed at the top. I.e. it
  /// is possible to have pages start at arbitrary rows, not at the boundaries
  /// of pages as determined by page size.
  void goToRow(int rowIndex) {
    _assertIfNotAttached();
    // if (_state != null) {
    //   _state!.setState(() {
    //     _state!._firstRowIndex =
    //         math.max(math.min(_state!._rowCount - 1, rowIndex), 0);
    //   });
    //}
    _state?.pageTo(rowIndex, false);
  }

  /// Switches to the page where the given row is present.
  /// The row can be in the middle of the page, pages are aligned
  /// to page size. E.g. with page size 5 going to index 6 (rows #7)
  /// will set page starting index at 5 (#6)
  void goToPageWithRow(int rowIndex) {
    _assertIfNotAttached();
    _state?.pageTo(rowIndex);
  }
}

/// The default value for [rowsPerPage].
///
/// Useful when initializing the field that will hold the current
/// [rowsPerPage], when implemented [onRowsPerPageChanged].
const int defaultRowsPerPage = 10;

/// In-place replacement of standard [PaginatedDataTable] widget, mimics it API.
/// Has the header row and paginatior always fixed to top and bottom (correspondingly).
/// Core of the table (with data rows) is scrollable and stretching to max width/height of it's container.
/// You can set minimal width of the table via [minWidth] property and Flex behavior of
/// table core via [fit] property.
/// By using [DataColumn2] instead of [DataColumn] it is possible to control
/// relative column sizes (setting them to S, M and L). [DataRow2] provides
/// row-level tap event handlers.
/// See also:
///
///  * [DataTable2], which is not paginated.
class PaginatedDataTable2 extends StatefulWidget {
  /// Check out [PaginatedDataTable] for the API decription.
  /// Key differences are [minWidth] and [fit] properties.
  PaginatedDataTable2({
    Key? key,
    this.header,
    this.actions,
    required this.columns,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSelectAll,
    this.dataRowHeight = kMinInteractiveDimension,
    this.headingRowHeight = 56.0,
    this.horizontalMargin = 24.0,
    this.columnSpacing = 56.0,
    this.showCheckboxColumn = true,
    this.showFirstLastButtons = false,
    this.initialFirstRowIndex = 0,
    this.onPageChanged,
    this.rowsPerPage = defaultRowsPerPage,
    this.availableRowsPerPage = const <int>[
      defaultRowsPerPage,
      defaultRowsPerPage * 2,
      defaultRowsPerPage * 5,
      defaultRowsPerPage * 10
    ],
    this.onRowsPerPageChanged,
    this.dragStartBehavior = DragStartBehavior.start,
    required this.source,
    this.checkboxHorizontalMargin,
    this.wrapInCard = true,
    this.minWidth,
    this.fit = FlexFit.tight,
    this.hidePaginator = false,
    this.controller,
    this.scrollController,
    this.empty,
    this.border,
    this.autoRowsToHeight = false,
    this.smRatio = 0.67,
    this.lmRatio = 1.2,
  })  : assert(actions == null || (header != null)),
        assert(columns.isNotEmpty),
        assert(sortColumnIndex == null ||
            (sortColumnIndex >= 0 && sortColumnIndex < columns.length)),
        assert(rowsPerPage > 0),
        assert(() {
          if (onRowsPerPageChanged != null && autoRowsToHeight == false)
            assert(availableRowsPerPage.contains(rowsPerPage));
          return true;
        }()),
        super(key: key);

  final bool wrapInCard;

  /// The table card's optional header.
  ///
  /// This is typically a [Text] widget, but can also be a [Row] of
  /// [TextButton]s. To show icon buttons at the top end side of the table with
  /// a header, set the [actions] property.
  ///
  /// If items in the table are selectable, then, when the selection is not
  /// empty, the header is replaced by a count of the selected items. The
  /// [actions] are still visible when items are selected.
  final Widget? header;

  /// Icon buttons to show at the top end side of the table. The [header] must
  /// not be null to show the actions.
  ///
  /// Typically, the exact actions included in this list will vary based on
  /// whether any rows are selected or not.
  ///
  /// These should be size 24.0 with default padding (8.0).
  final List<Widget>? actions;

  /// The configuration and labels for the columns in the table.
  final List<DataColumn> columns;

  /// The current primary sort key's column.
  ///
  /// See [DataTable.sortColumnIndex].
  final int? sortColumnIndex;

  /// Whether the column mentioned in [sortColumnIndex], if any, is sorted
  /// in ascending order.
  ///
  /// See [DataTable.sortAscending].
  final bool sortAscending;

  /// Invoked when the user selects or unselects every row, using the
  /// checkbox in the heading row.
  ///
  /// See [DataTable.onSelectAll].
  final ValueSetter<bool?>? onSelectAll;

  /// The height of each row (excluding the row that contains column headings).
  ///
  /// This value is optional and defaults to kMinInteractiveDimension if not
  /// specified.
  final double dataRowHeight;

  /// The height of the heading row.
  ///
  /// This value is optional and defaults to 56.0 if not specified.
  final double headingRowHeight;

  /// The horizontal margin between the edges of the table and the content
  /// in the first and last cells of each row.
  ///
  /// When a checkbox is displayed, it is also the margin between the checkbox
  /// the content in the first data column.
  ///
  /// This value defaults to 24.0 to adhere to the Material Design specifications.
  ///
  /// If [checkboxHorizontalMargin] is null, then [horizontalMargin] is also the
  /// margin between the edge of the table and the checkbox, as well as the
  /// margin between the checkbox and the content in the first data column.
  final double horizontalMargin;

  /// The horizontal margin between the contents of each data column.
  ///
  /// This value defaults to 56.0 to adhere to the Material Design specifications.
  final double columnSpacing;

  /// {@macro flutter.material.dataTable.showCheckboxColumn}
  final bool showCheckboxColumn;

  /// Flag to display the pagination buttons to go to the first and last pages.
  final bool showFirstLastButtons;

  /// The index of the first row to display when the widget is first created.
  final int? initialFirstRowIndex;

  /// Invoked when the user switches to another page.
  ///
  /// The value is the index of the first row on the currently displayed page.
  final ValueChanged<int>? onPageChanged;

  /// The number of rows to show on each page.
  ///
  /// See also:
  ///
  ///  * [onRowsPerPageChanged]
  ///  * [defaultRowsPerPage]
  final int rowsPerPage;

  /// The options to offer for the rowsPerPage.
  ///
  /// The current [rowsPerPage] must be a value in this list.
  ///
  /// The values in this list should be sorted in ascending order.
  final List<int> availableRowsPerPage;

  /// Invoked when the user selects a different number of rows per page.
  ///
  /// If this is null, then the value given by [rowsPerPage] will be used
  /// and no affordance will be provided to change the value.
  final ValueChanged<int?>? onRowsPerPageChanged;

  /// The data source which provides data to show in each row. Must be non-null.
  ///
  /// This object should generally have a lifetime longer than the
  /// [PaginatedDataTable2] widget itself; it should be reused each time the
  /// [PaginatedDataTable2] constructor is called.
  final DataTableSource source;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// Horizontal margin around the checkbox, if it is displayed.
  ///
  /// If null, then [horizontalMargin] is used as the margin between the edge
  /// of the table and the checkbox, as well as the margin between the checkbox
  /// and the content in the first data column. This value defaults to 24.0.
  final double? checkboxHorizontalMargin;

  /// If set, the table will stop shrinking below the threshold and provide
  /// horizontal scrolling. Useful for the cases with narrow screens (e.g. portrait phone orientation)
  /// and lots of columns (that get messed with little space)
  final double? minWidth;

  /// Data rows are wrapped in Flexible widget, this property sets its' fit property.
  /// When ther're few rows it determines if the core
  /// of the table must grow and fill the contrainer (FlexFit.tight - useful if
  /// you want the paginator to stick to the bottom when there're few rows) or
  /// of you want to have the table to take minimal space and do not have bottom
  /// pager stick to the bottom (FlexFit.loose)
  final FlexFit fit;

  /// Set vertical and horizontal borders between cells, as well as outside borders around table.
  /// NOTE: setting this field will disable standard horizontal dividers which are controlled by
  /// themes and [dividerThickness] property
  final TableBorder? border;

  ///If true rows per page is set to fill available height so that no scroll bar is ever displayed.
  ///[rowsPerPage] is ignore when this field is set to true
  final bool autoRowsToHeight;

  /// Placeholder widget which is displayed whenever the data rows are empty.
  /// The widget will be displayed below column
  final Widget? empty;

  /// Determines ratio of Small column's width to Medium column's width.
  /// I.e. 0.5 means that Small column is twice narower than Medium column.
  final double smRatio;

  /// Determines ratio of Large column's width to Medium column's width.
  /// I.e. 2.0 means that Large column is twice wider than Medium column.
  final double lmRatio;

  /// Hides the paginator at the bottom. Can be useful in case you decide create
  /// your own paginator and control the widget via [PaginatedDataTable2.controller]
  final bool hidePaginator;

  /// Used to comntrol widget's state externally and trigger actions. See
  /// [PaginatorController]
  final PaginatorController? controller;

  /// Exposes scroll controller of the SingleChildScrollView that makes data rows horizontally scrollable
  final ScrollController? scrollController;

  @override
  PaginatedDataTable2State createState() => PaginatedDataTable2State();
}

/// Holds the state of a [PaginatedDataTable2].
///
/// The table can be programmatically paged using the [pageTo] method.
class PaginatedDataTable2State extends State<PaginatedDataTable2> {
  late int _firstRowIndex;
  late int _rowCount;
  late bool _rowCountApproximate;
  int _selectedRowCount = 0;
  final Map<int, DataRow?> _rows = <int, DataRow?>{};
  int _effectiveRowsPerPage = -1;
  int _prevRowsPerPageForAutoRows = -1;

  @override
  void setState(VoidCallback fn) {
    // Notifying listeners in the next message queue pass
    // Doing that in the current call somehow messes with update
    // lifecycle when using async table
    if (widget.controller != null)
      Future.delayed(Duration(milliseconds: 0),
          () => widget.controller?._notifyListeners());
    //widget.controller?._notifyListeners();
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _firstRowIndex = PageStorage.of(context)?.readState(context) as int? ??
        widget.initialFirstRowIndex ??
        0;
    widget.source.addListener(_handleDataSourceChanged);
    _effectiveRowsPerPage = widget.rowsPerPage;
    widget.controller?._attach(this);
    _handleDataSourceChanged();
  }

  @override
  void didUpdateWidget(PaginatedDataTable2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      oldWidget.source.removeListener(_handleDataSourceChanged);
      widget.source.addListener(_handleDataSourceChanged);
      _handleDataSourceChanged();
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.source.removeListener(_handleDataSourceChanged);
    super.dispose();
  }

  void _handleDataSourceChanged() {
    setState(() {
      _rowCount = widget.source.rowCount;
      _rowCountApproximate = widget.source.isRowCountApproximate;
      _selectedRowCount = widget.source.selectedRowCount;
      _rows.clear();
    });
  }

  // Aligns row index to page size returning the first index of a page
  // that contains given row
  int _alignRowIndex(int rowIndex, int rowsPerPage) {
    return ((rowIndex + 1) ~/ rowsPerPage) * rowsPerPage;
  }

  /// Ensures that the given row is visible. [align] params makes sure that
  /// starting index will be aligned to page size, e.g. if page size is 5, row with
  /// index 7 (ordinal number 8) is requested, rather than showing rows 8 - 12
  /// starting page at row 7 it will make first row index 5 displaying 6-10
  void pageTo(int rowIndex, [bool align = true]) {
    final int oldFirstRowIndex = _firstRowIndex;
    setState(() {
      _firstRowIndex = align
          ? _alignRowIndex(rowIndex, _effectiveRowsPerPage)
          : math.max(math.min(_rowCount - 1, rowIndex), 0);
    });
    if ((widget.onPageChanged != null) && (oldFirstRowIndex != _firstRowIndex))
      widget.onPageChanged!(_firstRowIndex);
  }

  DataRow _getBlankRowFor(int index) {
    return DataRow.byIndex(
      index: index,
      cells: widget.columns
          .map<DataCell>((DataColumn column) => DataCell.empty)
          .toList(),
    );
  }

  DataRow _getProgressIndicatorRowFor(int index) {
    bool haveProgressIndicator = false;
    final List<DataCell> cells =
        widget.columns.map<DataCell>((DataColumn column) {
      if (!column.numeric) {
        haveProgressIndicator = true;
        return const DataCell(CircularProgressIndicator());
      }
      return DataCell.empty;
    }).toList();
    if (!haveProgressIndicator) {
      haveProgressIndicator = true;
      cells[0] = const DataCell(CircularProgressIndicator());
    }
    return DataRow.byIndex(
      index: index,
      cells: cells,
    );
  }

  // Flag to be used by AsyncDataTable to show empty table when loading data
  bool _showNothing = false;

  List<DataRow> _getRows(int firstRowIndex, int rowsPerPage) {
    final List<DataRow> result = <DataRow>[];

    if ((widget.empty != null && widget.source.rowCount < 1) || _showNothing)
      return result; // If empty placeholder is provided - don't create blank rows

    final int nextPageFirstRowIndex = firstRowIndex + rowsPerPage;
    bool haveProgressIndicator = false;

    for (int index = firstRowIndex; index < nextPageFirstRowIndex; index += 1) {
      DataRow? row;
      if (index < _rowCount || _rowCountApproximate) {
        row = _rows.putIfAbsent(index, () => widget.source.getRow(index));
        if (row == null && !haveProgressIndicator) {
          row ??= _getProgressIndicatorRowFor(index);
          haveProgressIndicator = true;
        }
      }
      row ??= _getBlankRowFor(index);
      result.add(row);
    }
    return result;
  }

  void _handleFirst() {
    pageTo(0);
  }

  void _handlePrevious() {
    pageTo(math.max(_firstRowIndex - _effectiveRowsPerPage, 0));
  }

  void _handleNext() {
    pageTo(_firstRowIndex + _effectiveRowsPerPage);
  }

  void _handleLast() {
    pageTo(((_rowCount - 1) / _effectiveRowsPerPage).floor() *
        _effectiveRowsPerPage);
  }

  bool _isNextPageUnavailable() =>
      !_rowCountApproximate &&
      (_firstRowIndex + _effectiveRowsPerPage >= _rowCount);

  final GlobalKey _tableKey = GlobalKey();

  Widget _getHeader() {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    double startPadding = widget.horizontalMargin;
    final List<Widget> headerWidgets = <Widget>[];

    if (_selectedRowCount == 0 && widget.header != null) {
      headerWidgets.add(Expanded(child: widget.header!));
      if (widget.header is ButtonBar) {
        // We adjust the padding when a button bar is present, because the
        // ButtonBar introduces 2 pixels of outside padding, plus 2 pixels
        // around each button on each side, and the button itself will have 8
        // pixels internally on each side, yet we want the left edge of the
        // inside of the button to line up with the 24.0 left inset.
        startPadding = 12.0;
      }
    } else if (widget.header != null) {
      headerWidgets.add(Expanded(
        child: Text(localizations.selectedRowCountTitle(_selectedRowCount)),
      ));
    }
    if (widget.actions != null) {
      headerWidgets.addAll(widget.actions!.map<Widget>((Widget action) {
        return Padding(
          // 8.0 is the default padding of an icon button
          padding: const EdgeInsetsDirectional.only(start: 24.0 - 8.0 * 2.0),
          child: action,
        );
      }).toList());
    }

    return Semantics(
      container: true,
      child: DefaultTextStyle(
        // These typographic styles aren't quite the regular ones. We pick the closest ones from the regular
        // list and then tweak them appropriately.
        // See https://material.io/design/components/data-tables.html#tables-within-cards
        style: _selectedRowCount > 0
            ? themeData.textTheme.subtitle1!
                .copyWith(color: themeData.colorScheme.secondary)
            : themeData.textTheme.headline6!
                .copyWith(fontWeight: FontWeight.w400),
        child: IconTheme.merge(
          data: const IconThemeData(opacity: 0.54),
          child: Ink(
            height: 64.0,
            color:
                _selectedRowCount > 0 ? themeData.secondaryHeaderColor : null,
            child: Padding(
              padding:
                  EdgeInsetsDirectional.only(start: startPadding, end: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: headerWidgets,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTable(BoxConstraints constraints) {
    return Flexible(
      fit: widget.fit,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: constraints.minWidth),
        child: DataTable2(
          key: _tableKey,
          columns: widget.columns,
          sortColumnIndex: widget.sortColumnIndex,
          sortAscending: widget.sortAscending,
          onSelectAll: widget.onSelectAll,
          // Make sure no decoration is set on the DataTable
          // from the theme, as its already wrapped in a Card.
          decoration: const BoxDecoration(),
          dataRowHeight: widget.dataRowHeight,
          headingRowHeight: widget.headingRowHeight,
          horizontalMargin: widget.horizontalMargin,
          checkboxHorizontalMargin: widget.checkboxHorizontalMargin,
          columnSpacing: widget.columnSpacing,
          showCheckboxColumn: widget.showCheckboxColumn,
          showBottomBorder: true,
          rows: _getRows(_firstRowIndex, _effectiveRowsPerPage),
          minWidth: widget.minWidth,
          scrollController: widget.scrollController,
          empty: _showNothing ? null : widget.empty,
          border: widget.border,
          smRatio: widget.smRatio,
          lmRatio: widget.lmRatio,
        ),
      ),
    );
  }

  Widget _getFooter() {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    final TextStyle? footerTextStyle = themeData.textTheme.caption;
    final List<Widget> footerWidgets = <Widget>[];

    if (widget.onRowsPerPageChanged != null) {
      final List<Widget> availableRowsPerPage = widget.availableRowsPerPage
          .where((int value) =>
              value <= _rowCount || value == _effectiveRowsPerPage)
          .map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text('$value'),
        );
      }).toList();
      if (!widget.autoRowsToHeight) {
        footerWidgets.addAll(<Widget>[
          Container(
              width:
                  14.0), // to match trailing padding in case we overflow and end up scrolling
          Text(localizations.rowsPerPageTitle),
          ConstrainedBox(
            constraints: const BoxConstraints(
                minWidth: 64.0), // 40.0 for the text, 24.0 for the icon
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  items: availableRowsPerPage.cast<DropdownMenuItem<int>>(),
                  value: _effectiveRowsPerPage,
                  onChanged: (r) {
                    _setRowsPerPage(r);
                  },
                  style: footerTextStyle,
                  iconSize: 24.0,
                ),
              ),
            ),
          ),
        ]);
      }
    }

    footerWidgets.addAll(<Widget>[
      Container(width: 32.0),
      Text(
        localizations.pageRowsInfoTitle(
          _firstRowIndex + 1,
          _firstRowIndex + _effectiveRowsPerPage,
          _rowCount,
          _rowCountApproximate,
        ),
      ),
      Container(width: 32.0),
      if (widget.showFirstLastButtons)
        IconButton(
          icon: const Icon(Icons.skip_previous),
          padding: EdgeInsets.zero,
          tooltip: localizations.firstPageTooltip,
          onPressed: _firstRowIndex <= 0 ? null : _handleFirst,
        ),
      IconButton(
        icon: const Icon(Icons.chevron_left),
        padding: EdgeInsets.zero,
        tooltip: localizations.previousPageTooltip,
        onPressed: _firstRowIndex <= 0 ? null : _handlePrevious,
      ),
      Container(width: 24.0),
      IconButton(
        icon: const Icon(Icons.chevron_right),
        padding: EdgeInsets.zero,
        tooltip: localizations.nextPageTooltip,
        onPressed: _isNextPageUnavailable() ? null : _handleNext,
      ),
      if (widget.showFirstLastButtons)
        IconButton(
          icon: const Icon(Icons.skip_next),
          padding: EdgeInsets.zero,
          tooltip: localizations.lastPageTooltip,
          onPressed: _isNextPageUnavailable() ? null : _handleLast,
        ),
      Container(width: 14.0),
    ]);

    return DefaultTextStyle(
      style: footerTextStyle!,
      child: IconTheme.merge(
        data: const IconThemeData(opacity: 0.54),
        child: SizedBox(
          height: 56.0,
          child: SingleChildScrollView(
            dragStartBehavior: widget.dragStartBehavior,
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: footerWidgets,
            ),
          ),
        ),
      ),
    );
  }

  void _setRowsPerPage(int? r, [bool wrapInSetState = true]) {
    if (r != null) {
      var f = () {
        _effectiveRowsPerPage = r;
        if (widget.onRowsPerPageChanged != null) {
          widget.onRowsPerPageChanged!(r);
        }
      };
      if (wrapInSetState)
        setState(f);
      else
        f();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        bool isHeaderPresent = widget.header != null || widget.actions != null;
        if (widget.autoRowsToHeight) {
          _effectiveRowsPerPage = math.max(
              ((constraints.maxHeight -
                          widget.headingRowHeight -
                          8 * (widget.wrapInCard ? 1 : 0) // card paddings
                          -
                          64 * (isHeaderPresent ? 1 : 0) //header
                          -
                          56 * (widget.hidePaginator ? 0 : 1) // footer
                      ) /
                      widget.dataRowHeight)
                  .floor(),
              1);
          if (_prevRowsPerPageForAutoRows != _effectiveRowsPerPage) {
            //if (prevRowsPerPageForAutoRows != -1)
            // Also call it on the first build to let clients know
            // how many rows were autocalculated
            //widget.onRowsPerPageChanged?.call(_effectiveRowsPerPage);
            _setRowsPerPage(_effectiveRowsPerPage, false);
            // don't call setState here to avoid assertion
            // The following assertion was thrown building LayoutBuilder:
            // setState() or markNeedsBuild() called during build.
            _prevRowsPerPageForAutoRows = _effectiveRowsPerPage;
          }
        }
        assert(debugCheckHasMaterialLocalizations(context));

        // CARD

        Widget t = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isHeaderPresent) _getHeader(),
            _getTable(constraints),
            if (!widget.hidePaginator) _getFooter(),
          ],
        );

        if (widget.wrapInCard) t = Card(semanticContainer: false, child: t);

        return t;
      },
    );
  }
}
