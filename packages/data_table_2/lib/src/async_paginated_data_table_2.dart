part of 'paginated_data_table_2.dart';

enum _SourceState { none, ok, loading, error }

/// AsyncDataTableSource states:
/// none -> toggle/selectAllOnPage -> include
/// include -> toggle/deselectAllOnPage -> no
/// include -> selectAll -> exclude
/// none -> selectAll -> exclude
/// exclude -> deselectAll -> none
/// exclude -> toggle/selectAllOnPage/deselectAllOnPage -> exclude
enum SelectionState { none, include, exclude }

class AsyncRowsResponse {
  AsyncRowsResponse(this.totalRows, this.rows);
  final int totalRows;
  final List<DataRow> rows;
}

/// Implement this class and use it in conjunction with [AsyncPaginatedDataTable2]
/// to allow asynchronous data fetching.
/// Please overide [AsyncDataTableSource.getRows] and [DataTableSource.selectedRowCount]
/// to make it legible as a data source.
abstract class AsyncDataTableSource extends DataTableSource {
  _SourceState _state = _SourceState.none;

  _SourceState get state => _state;

  bool _debouncable = false;

  /// Highlights if there're any selected rows (SelectionState.none means there're not any)
  /// and how [selectionRowKeys] must be treated.
  /// If SelectionState.include is the status, it is assumed that by default
  /// all rows are considered deselected and only those items in [selectionRowKeys]
  /// are selected.
  /// If SelectionState.exclude is the status, it is assumed that by default
  /// all rows are considered selected and only those items in [selectionRowKeys]
  /// are de-selected - this can be usefull if yopu deal with scenarious when you need
  /// to have many more selected items than deselected (e.g. selecting all rows across
  /// hundres of pages and than deselecting certain ines).
  SelectionState _selectionState = SelectionState.none;

  SelectionState get selectionState => _selectionState;

  Set<LocalKey> _selectionRowKeys = {};

  /// Lists rows (their keys) which are treated as eitehr selected or deselected (see [selectionState])
  Set<LocalKey> get selectionRowKeys => _selectionRowKeys;

  Object? _error;
  Object? get error => _error;

  List<DataRow> _rows = [];
  int _totalRows = 0;
  int _firstRowAbsoluteIndex = 0;

  int _prevFetchSratIndex = 0;
  int _prevFetchCount = 0;

  /// Override this method to allow the data source asynchronously
  /// fetch data (e.g. from a server) and convert them to [DataRow]/[DataRow2]
  /// entities consumed by [AsyncPaginatedDataTable2] widget.
  /// Note that besides rows this method is also supposed to return
  /// the total number of available rows (both values are packed into [AsyncRowsResponse] instance
  /// returned from this method)
  Future<AsyncRowsResponse> getRows(int start, int end);

  DataRow _clone(DataRow row, bool? selected) {
    if (row is DataRow2) {
      return DataRow2(
          key: row.key,
          selected: selected == null ? row.selected : selected,
          onSelectChanged: row.onSelectChanged,
          color: row.color,
          cells: row.cells,
          onTap: row.onTap,
          onSecondaryTap: row.onSecondaryTap,
          onSecondaryTapDown: row.onSecondaryTapDown);
    }

    return DataRow(
      key: row.key,
      selected: selected == null ? row.selected : selected,
      onSelectChanged: row.onSelectChanged,
      color: row.color,
      cells: row.cells,
    );
  }

  // set row's seelcted property in accordance with included/excluded from selection items
  void _fixSelectedState(int rowIndex) {
    if (_selectionState == SelectionState.include) {
      if (!_rows[rowIndex].selected &&
          _selectionRowKeys.contains(_rows[rowIndex].key)) {
        _rows[rowIndex] = _clone(_rows[rowIndex], true);
      } else if (_rows[rowIndex].selected &&
          !_selectionRowKeys.contains(_rows[rowIndex].key)) {
        _rows[rowIndex] = _clone(_rows[rowIndex], false);
      }
    } else if (_selectionState == SelectionState.exclude) {
      if (!_rows[rowIndex].selected &&
          !_selectionRowKeys.contains(_rows[rowIndex].key)) {
        _rows[rowIndex] = _clone(_rows[rowIndex], true);
      } else if (_rows[rowIndex].selected &&
          _selectionRowKeys.contains(_rows[rowIndex].key)) {
        _rows[rowIndex] = _clone(_rows[rowIndex], false);
      }
    } else {
      //none
      if (_rows[rowIndex].selected) {
        _rows[rowIndex] = _clone(_rows[rowIndex], false);
      }
    }
  }

  void selectAll() {
    _selectionState = SelectionState.exclude;
    _selectionRowKeys.clear();
    notifyListeners();
  }

  void deselectAll() {
    _selectionState = SelectionState.none;
    _selectionRowKeys.clear();
    notifyListeners();
  }

  void selectAllOnThePage() {
    for (var i = 0; i < _rows.length; i++) {
      var r = _rows[i];
      assert(r.key != null, 'Row key can\'t be null');

      if (r.key != null) {
        if (_selectionState == SelectionState.none ||
            _selectionState == SelectionState.include) {
          _selectionRowKeys.add(r.key!);
        } else {
          //exclude
          _selectionRowKeys.remove(r.key!);
        }
        if (!_rows[i].selected) _rows[i] = _clone(r, true);
      }
    }
    if (_selectionState == SelectionState.none &&
        _selectionRowKeys.isNotEmpty) {
      _selectionState = SelectionState.include;
    }
    notifyListeners();
  }

  @override
  int get selectedRowCount => _selectionState == SelectionState.none
      ? 0
      : _selectionState == SelectionState.include
          ? _selectionRowKeys.length
          : _totalRows - _selectionRowKeys.length;

  void deselectAllOnThePage() {
    for (var i = 0; i < _rows.length; i++) {
      var r = _rows[i];
      assert(r.key != null, 'Row key can\'t be null');
      if (r.key != null) {
        if (_selectionState == SelectionState.none ||
            _selectionState == SelectionState.include) {
          _selectionRowKeys.remove(r.key!);
        } else {
          // exclude
          _selectionRowKeys.add(r.key!);
        }
        if (_rows[i].selected) _rows[i] = _clone(r, false);
      }
    }
    if (_selectionState == SelectionState.include &&
        _selectionRowKeys.isEmpty) {
      _selectionState = SelectionState.none;
    }
    notifyListeners();
  }

  void setRowSelection(LocalKey rowKey, bool selected) {
    var i = _rows.indexWhere((r) => r.key == rowKey);
    if (i > -1 && _rows[i].selected != selected) {
      _toggleRowSelection(i);
    }
  }

  void _toggleRowSelection(int i) {
    _rows[i] = _clone(_rows[i], !_rows[i].selected);
    if (_selectionState == SelectionState.none) {
      if (_rows[i].selected) {
        _selectionRowKeys.add(_rows[i].key!);
        _selectionState = SelectionState.include;
      }
    } else if (_selectionState == SelectionState.include) {
      if (_rows[i].selected) {
        _selectionRowKeys.add(_rows[i].key!);
      } else {
        _selectionRowKeys.remove(_rows[i].key!);
      }
      if (_selectionRowKeys.isEmpty) {
        _selectionState = SelectionState.none;
      }
    } else {
      // exclude
      if (_rows[i].selected) {
        _selectionRowKeys.remove(_rows[i].key!);
      } else {
        _selectionRowKeys.add(_rows[i].key!);
      }
    }

    notifyListeners();
  }

  /// This method triggers getRows() requesting same rows as the last time
  /// and intitaite update workflow (and thus rebuilding of [AsyncPaginatedDataTable2]
  /// attached to this data source). Can be used for sorting
  void refreshDatasource() {
    _fetchData(_prevFetchSratIndex, _prevFetchCount);
  }

  Timer? _debounceTimer;
  CancelableOperation<AsyncRowsResponse>? _fetchOpp;

  void _debounce(Function f, int milliseconds) {
    _debounceTimer?.cancel();
    _debounceTimer =
        Timer(Duration(milliseconds: milliseconds), f as void Function());
  }

  // If previously loaded rows encompass requested row range and forceReload
  // is false than no actual fetch will happen
  Future _fetchData(int startIndex, int count,
      [bool forceReload = true]) async {
    void fetch() async {
      try {
        _fetchOpp?.cancel();
        _fetchOpp = CancelableOperation<AsyncRowsResponse>.fromFuture(
            getRows(startIndex, count));
        var data = await _fetchOpp!.value;
        if (_fetchOpp!.isCanceled) return;
        //var data = await getRows(startIndex, count);
        _rows = data.rows;
        _totalRows = data.totalRows;
        _firstRowAbsoluteIndex = startIndex;
      } catch (e) {
        _rows = [];
        _totalRows = 0;
        _firstRowAbsoluteIndex = 0;
        _state = _SourceState.error;
        _error = e;
        notifyListeners();
        return;
      }

      _state = _SourceState.ok;
      _error = null;
      notifyListeners();
    }

    if (!_debouncable ||
        _debounceTimer == null ||
        (_debounceTimer != null && !_debounceTimer!.isActive)) {
      if (!forceReload &&
          _prevFetchSratIndex <= startIndex &&
          _prevFetchCount >= count &&
          _prevFetchCount > 0) {
        _prevFetchSratIndex = startIndex;
        _prevFetchCount = count;
        _state = _SourceState.ok;
        await Future(() => notifyListeners());
        return;
      }
      _prevFetchSratIndex = startIndex;
      _prevFetchCount = count;
      _state = _SourceState.loading;
      await Future(() => notifyListeners());
    }

    if (!_debouncable) {
      fetch();
    } else {
      _debounce(() {
        fetch();
      }, 700);
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index - _firstRowAbsoluteIndex < 0 ||
        index >= _rows.length + _firstRowAbsoluteIndex) return null;
    index -= _firstRowAbsoluteIndex;
    _fixSelectedState(index);

    return _rows[index];
  }

  @override
  int get rowCount => _totalRows;

  @override
  bool get isRowCountApproximate => false;
}

/// Should data source return less rows that ca
enum PageSyncApproach { doNothing, goToFirst, goToLast }

/// Asynchronous version of PaginatedDataTable2 which relies on data source
/// returning data rows wrappd in [Future]. Provides a straightworward way
/// of integrating data table with remote back-end and is loaded with
/// convenienece features such as error handling, reloading etc.
class AsyncPaginatedDataTable2 extends PaginatedDataTable2 {
  AsyncPaginatedDataTable2(
      {Key? key,
      Widget? header,
      List<Widget>? actions,
      required List<DataColumn> columns,
      int? sortColumnIndex,
      bool sortAscending = true,
      ValueSetter<bool?>? onSelectAll,
      double dataRowHeight = kMinInteractiveDimension,
      double headingRowHeight = 56,
      double horizontalMargin = 24,
      double columnSpacing = 56,
      bool showCheckboxColumn = true,
      bool showFirstLastButtons = false,
      int initialFirstRowIndex = 0,
      ValueChanged<int>? onPageChanged,
      int rowsPerPage = defaultRowsPerPage,
      List<int> availableRowsPerPage = const <int>[
        defaultRowsPerPage,
        defaultRowsPerPage * 2,
        defaultRowsPerPage * 5,
        defaultRowsPerPage * 10
      ],
      ValueChanged<int?>? onRowsPerPageChanged,
      DragStartBehavior dragStartBehavior = DragStartBehavior.start,
      required AsyncDataTableSource source,
      double? checkboxHorizontalMargin,
      bool wrapInCard = true,
      double? minWidth,
      FlexFit fit = FlexFit.tight,
      bool hidePaginator = false,
      PaginatorController? controller,
      ScrollController? scrollController,
      Widget? empty,
      this.loading,
      this.errorBuilder,
      this.pageSyncApproach = PageSyncApproach.doNothing,
      TableBorder? border,
      bool autoRowsToHeight = false,
      double smRatio = 0.67,
      double lmRatio = 1.2})
      : super(
            key: key,
            header: header,
            actions: actions,
            columns: columns,
            sortColumnIndex: sortColumnIndex,
            sortAscending: sortAscending,
            onSelectAll: onSelectAll,
            dataRowHeight: dataRowHeight,
            headingRowHeight: headingRowHeight,
            horizontalMargin: horizontalMargin,
            columnSpacing: columnSpacing,
            showCheckboxColumn: showCheckboxColumn,
            showFirstLastButtons: showFirstLastButtons,
            initialFirstRowIndex: initialFirstRowIndex,
            onPageChanged: onPageChanged,
            rowsPerPage: rowsPerPage,
            availableRowsPerPage: availableRowsPerPage,
            onRowsPerPageChanged: onRowsPerPageChanged,
            dragStartBehavior: dragStartBehavior,
            source: source,
            checkboxHorizontalMargin: checkboxHorizontalMargin,
            wrapInCard: wrapInCard,
            minWidth: minWidth,
            fit: fit,
            hidePaginator: hidePaginator,
            controller: controller,
            scrollController: scrollController,
            empty: empty,
            border: border,
            autoRowsToHeight: autoRowsToHeight,
            smRatio: smRatio,
            lmRatio: lmRatio);

  /// Widget that is goin to be displayed while loading is in progress
  /// If no widget is specified the following defaul widget will be disoplayed:
  /// ```
  /// Center(
  ///   child: SizedBox(
  ///     width: 64, height: 16, child: LinearProgressIndicator()))
  /// ```
  final Widget? loading;

  /// The function allows displaying custom widget on top of table should an error happen.
  /// E.g. data source faild to load data
  final Widget Function(Object? error)? errorBuilder;

  /// Should a data source return less rows than required to fill the current
  /// page of the table (e.g. when regresshin with a new filter value),
  /// the widget can take 3 actions (see [PageSyncApproach]):
  /// 1. Do nothing and display empty rows (e.g. rows 51-60 of 45)
  /// 2. Make another request to thу data source fetching the very first page (e.g. rows 0-10 of 45 )
  /// 3. Make another request fetchiung the very last page (e.g. rows 41 - 45 of 45)
  final PageSyncApproach pageSyncApproach;

  @override
  PaginatedDataTable2State createState() => AsyncPaginatedDataTable2State();
}

enum _TableOperationInProgress { none, pageTo, pageSize }

class AsyncPaginatedDataTable2State extends PaginatedDataTable2State {
  _TableOperationInProgress _operationInProgress =
      _TableOperationInProgress.none;

  int _rowIndexRequested = -1;
  int _rowsPerPageRequested = -1;
  bool _aligned = true;

  @override
  void pageTo(int rowIndex, [bool align = true]) {
    if (_operationInProgress == _TableOperationInProgress.none) {
      _aligned = align;
      // int oldFirstRowIndex = _firstRowIndex;
      _operationInProgress = _TableOperationInProgress.pageTo;
      // if row requested happens to be outside the available range - change it to the last aligned page
      if (rowIndex > _rowCount - 1) {
        _rowIndexRequested = _lastAligned(rowIndex);
      } else
        _rowIndexRequested = align
            ? _alignRowIndex(rowIndex, _effectiveRowsPerPage)
            : math.max(math.min(_rowCount - 1, rowIndex), 0);
      var source = widget.source as AsyncDataTableSource;
      source._fetchData(_rowIndexRequested, _effectiveRowsPerPage);
    }
  }

  int _lastAligned(int rowIndex) {
    return math.min(
        ((rowIndex + 1) / _effectiveRowsPerPage).floor() *
            _effectiveRowsPerPage,
        (_rowCount / _effectiveRowsPerPage).floor() * _effectiveRowsPerPage);
  }

  @override
  void _setRowsPerPage(int? r, [bool wrapInSetState = true]) {
    if (r != null) {
      _operationInProgress = _TableOperationInProgress.pageSize;
      _rowsPerPageRequested = r;
      _rowIndexRequested = _firstRowIndex;
      var source = widget.source as AsyncDataTableSource;
      source._fetchData(_firstRowIndex, r, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var source = widget.source as AsyncDataTableSource;
    var w = widget as AsyncPaginatedDataTable2;

    Widget loading() {
      var x = super.build(context);
      return Stack(fit: StackFit.expand, children: [
        x,
        w.loading != null
            ? w.loading!
            : Center(
                child: SizedBox(
                    width: 64, height: 16, child: LinearProgressIndicator())),
      ]);
    }

    source._debouncable = widget.autoRowsToHeight;

    if (source.state == _SourceState.none) {
      _showNothing = true;
      var x = super.build(context);

      if (!widget.autoRowsToHeight)
        source._fetchData(_firstRowIndex, _effectiveRowsPerPage);

      return x;
    } else if (source.state == _SourceState.loading) {
      //_showNothing = true;

      return loading();
    } else if (source.state == _SourceState.error) {
      _showNothing = true;
      return w.errorBuilder != null
          ? w.errorBuilder!(source._error)
          : SizedBox();
    }

    // SourceState.ok
    _showNothing = false;
    if (_operationInProgress == _TableOperationInProgress.pageTo) {
      _operationInProgress = _TableOperationInProgress.none;

      super.pageTo(_rowIndexRequested, _aligned);
    } else if (_operationInProgress == _TableOperationInProgress.pageSize) {
      _operationInProgress = _TableOperationInProgress.none;
      _firstRowIndex = _rowIndexRequested;
      super._setRowsPerPage(_rowsPerPageRequested);
    }
    // current row is beyond max row
    if (_firstRowIndex >= _rowCount &&
        w.pageSyncApproach != PageSyncApproach.doNothing &&
        _firstRowIndex >= _effectiveRowsPerPage) {
      if (w.pageSyncApproach == PageSyncApproach.goToFirst) {
        pageTo(0);
      } else {
        pageTo(((_rowCount - 1) / _effectiveRowsPerPage).floor() *
            _effectiveRowsPerPage);
      }

      return loading();
    }

    return super.build(context);
  }
}
