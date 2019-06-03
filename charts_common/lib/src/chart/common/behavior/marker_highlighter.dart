// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import '../base_chart.dart' show BaseChart, LifecycleListener;
import '../processed_series.dart' show MutableSeries;
import '../selection_model/selection_model.dart'
    show SelectionModel, SelectionModelType;
import 'chart_behavior.dart' show ChartBehavior;

/// Chart behavior that monitors the specified [SelectionModel] and darkens the
/// color for selected data.
///
/// This is typically used for bars and pies to highlight segments.
///
/// It is used in combination with SelectNearest to update the selection model
/// and expand selection out to the marker value.
class MarkerHighlighter<D> implements ChartBehavior<D> {
  final SelectionModelType selectionModelType;

  BaseChart<D> _chart;

  _MarkerLayoutView _view;

  LifecycleListener<D> _lifecycleListener;

  MarkerHighlighter([this.selectionModelType = SelectionModelType.info]) {
    _lifecycleListener =
        new LifecycleListener<D>(onPostprocess: _showMarkerFunctions);
  }

  void _selectionChanged(SelectionModel selectionModel) {
    _chart.redraw(skipLayout: true, skipAnimation: true);
  }

  void _showMarkerFunctions(List<MutableSeries<D>> seriesList) {
    SelectionModel selectionModel =
        _chart.getSelectionModel(selectionModelType);
    final _datum = selectionModel.selectedDatum;
    final _index = _datum.first.index;
    final _values = List<String>();

    _datum.forEach((datum) {
      final _name = datum.series.displayName;
      final _value = (datum.series.data[_index] as AssetValue).value;
      _values.add('$_name:$_value');
    });

    print(_values.join('\n'));
//    seriesList.forEach((MutableSeries<D> series) {
//      final origColorFn = series.colorFn;
//
//      if (origColorFn != null) {
//        series.colorFn = (int index) {
//          final origColor = origColorFn(index);
//          if (selectionModel.isDatumSelected(series, index)) {
//            return origColor.darker;
//          } else {
//            return origColor;
//          }
//        };
//      }
//    });
  }

  @override
  void attachTo(BaseChart<D> chart) {
    _chart = chart;
    _view = _MarkerLayoutView<D>();

    chart.addView(_view);

    chart.addLifecycleListener(_lifecycleListener);
    chart
        .getSelectionModel(selectionModelType)
        .addSelectionChangedListener(_selectionChanged);
  }

  @override
  void removeFrom(BaseChart chart) {
    chart.removeView(_view);
    chart
        .getSelectionModel(selectionModelType)
        .removeSelectionChangedListener(_selectionChanged);
    chart.removeLifecycleListener(_lifecycleListener);
  }

  @override
  String get role => 'markerHighlight-${selectionModelType.toString()}';
}

class _MarkerLayoutView<D> extends LayoutView {

  Rectangle<int> _drawAreaBounds;

  Rectangle<int> get drawBounds => _drawAreaBounds;

  GraphicsFactory _graphicsFactory;

  @override
  GraphicsFactory get graphicsFactory => _graphicsFactory;

  @override
  set graphicsFactory(GraphicsFactory value) {
    _graphicsFactory = value;
  }

  @override
  ViewMeasuredSizes measure(int maxWidth, int maxHeight) {
    return null;
  }

  @override
  void layout(Rectangle<int> componentBounds, Rectangle<int> drawAreaBounds) {
    this._drawAreaBounds = drawAreaBounds;
  }

  @override
  void paint(ChartCanvas canvas, double animationPercent) {

  }

  @override
  Rectangle<int> get componentBounds => this._drawAreaBounds;

  @override
  bool get isSeriesRenderer => false;
}
