import React, { Component } from "react";
import PropTypes from "prop-types";
import shouldUpdate from "recompose/shouldUpdate";
import TableBody from "@material-ui/core/TableBody";
import classnames from "classnames";

import {
  SortableContainer,
  SortableElement,
  arrayMove
} from "react-sortable-hoc";

import DatagridRow from "./DatagridRow";

// const DragHandle = SortableHandle(() => <span>::</span>); // This can be any component you want

const SortableItem = SortableElement(
  ({
    id,
    basePath,
    classes,
    rowIndex,
    hasBulkActions,
    onToggleItem,
    data,
    resource,
    selectedIds,
    hover,
    rowStyle,
    children
  }) => {
    return (
      <DatagridRow
        basePath={basePath}
        classes={classes}
        className={classnames(classes.row, {
          [classes.rowEven]: rowIndex % 2 === 0,
          [classes.rowOdd]: rowIndex % 2 !== 0
        })}
        hasBulkActions={hasBulkActions}
        id={id}
        index={rowIndex}
        key={id}
        onToggleItem={onToggleItem}
        record={data[id]}
        resource={resource}
        selected={selectedIds.includes(id)}
        hover={hover}
        style={rowStyle ? rowStyle(data[id], rowIndex) : null}
      >
        {children}
      </DatagridRow>
    );
  }
);

// const SortableList =
//   ({ ids,
//     className, basePath, classes, hasBulkActions,
//      onToggleItem, data, resource, selectedIds, rowStyle, children, ...rest
//     })
//   => {
//     return (

//       );
//   }

const SortableList = ({
  ids,
  className,
  basePath,
  classes,
  hasBulkActions,
  onToggleItem,
  data,
  hover,
  resource,
  selectedIds,
  rowStyle,
  children,
  ...rest
}) => (
  <TableBody className={classnames("datagrid-body", className)} {...rest}>
    {ids.map((id, rowIndex) => {
      return (
        <SortableItem
          key={id}
          index={rowIndex}
          basePath={basePath}
          classes={classes}
          rowIndex={rowIndex}
          hasBulkActions={hasBulkActions}
          onToggleItem={onToggleItem}
          data={data}
          resource={resource}
          selectedIds={selectedIds}
          hover={hover}
          rowStyle={rowStyle}
          children={children}
        />
      );
    })}
  </TableBody>
);

class DatagridBody extends Component {
  state = {
    ids: ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6"]
  };
  componentWillReceiveProps() {
    this.setState({ ids: this.props.ids });
  }
  render() {
    const {
      basePath,
      classes,
      className,
      resource,
      children,
      hasBulkActions,
      hover,
      ids,
      isLoading,
      data,
      selectedIds,
      styles,
      rowStyle,
      onToggleItem,
      version,
      ...rest
    } = this.props;
    return <SortableList ids={this.state.ids} {...this.props} />;
  }
}

DatagridBody.propTypes = {
  basePath: PropTypes.string,
  classes: PropTypes.object,
  className: PropTypes.string,
  children: PropTypes.node,
  data: PropTypes.object.isRequired,
  hasBulkActions: PropTypes.bool.isRequired,
  hover: PropTypes.bool,
  ids: PropTypes.arrayOf(PropTypes.any).isRequired,
  isLoading: PropTypes.bool,
  onToggleItem: PropTypes.func,
  resource: PropTypes.string,
  rowStyle: PropTypes.func,
  selectedIds: PropTypes.arrayOf(PropTypes.any).isRequired,
  styles: PropTypes.object,
  version: PropTypes.number
};

DatagridBody.defaultProps = {
  data: {},
  hasBulkActions: false,
  ids: []
};

const areArraysEqual = (arr1, arr2) =>
  arr1.length == arr2.length && arr1.every((v, i) => v === arr2[i]);

const PureDatagridBody = shouldUpdate(
  (props, nextProps) =>
    props.version !== nextProps.version ||
    nextProps.isLoading === false ||
    !areArraysEqual(props.ids, nextProps.ids) ||
    props.data !== nextProps.data
)(DatagridBody);

// trick material-ui Table into thinking this is one of the child type it supports
PureDatagridBody.muiName = "TableBody";

// class SortableComponent extends Component {
//   state = {
//     items: ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6"]
//   };
//   onSortEnd = ({ oldIndex, newIndex }) => {
//     this.setState({
//       items: arrayMove(this.state.items, oldIndex, newIndex)
//     });
//   };
//   render() {
//     return <SortableList items={this.state.items} onSortEnd={this.onSortEnd} />;
//   }
// }

export default PureDatagridBody;
