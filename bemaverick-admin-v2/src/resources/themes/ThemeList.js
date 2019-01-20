import Chip from "@material-ui/core/Chip";
import { withStyles } from "@material-ui/core/styles";
import React, { Children, cloneElement } from "react";
import {
  BooleanField,
  BooleanInput,
  Datagrid,
  DateField,
  EditButton,
  Filter,
  List,
  NumberField,
  Responsive,
  SimpleList,
  TextField,
  ImageField
} from "react-admin"; // eslint-disable-line import/no-unresolved
import PremiumField from "components/PremiumField";
import PremiumIcon from "@material-ui/icons/Lock";

import SortableDatagrid from "components/SortableDatagrid";

// const QuickFilter = translate(({ label, translate }) => (
//   <Chip style={{ marginBottom: 8 }} label={translate(label)} />
// ));
const QuickFilter = ({ label }) => (
  <Chip style={{ marginBottom: 8 }} label={label} />
);

const ThemeFilter = props => (
  <Filter {...props}>
    {/* <QuickFilter
      label="resources.themes.fields.active"
      source="active"
      defaultValue
    /> */}
    <BooleanInput source="active" alwaysOn />
  </Filter>
);

const styles = theme => ({
  title: {
    maxWidth: "20em",
    overflow: "hidden",
    textOverflow: "ellipsis",
    whiteSpace: "nowrap"
  },
  hiddenOnSmallScreens: {
    [theme.breakpoints.down("md")]: {
      display: "none"
    }
  },
  publishedAt: { fontStyle: "italic" },
  backgroundImage: {
    maxHeight: "40px"
  },
  leftAvatar: {
    width: "250%",
    position: "absolute",
    top: "0px",
    left: "0px",
    backgroundColor: "#fff"
  }
});

const ThemeListActionToolbar = withStyles({
  toolbar: {
    alignItems: "center",
    display: "flex"
  }
})(({ classes, children, ...props }) => (
  <div className={classes.toolbar}>
    {Children.map(children, button => cloneElement(button, props))}
  </div>
));

const ThemeList = withStyles(styles)(({ classes, ...props }) => (
  <List
    {...props}
    filters={<ThemeFilter />}
    bulkActions={false}
    // sort={{ field: "sortOrder", order: "ASC" }}
    filterDefaultValues={{ active: true }}
  >
    <Responsive
      small={
        <SimpleList
          key={record => {
            // console.log("record", record);
            return record._id;
          }}
          primaryText={record => record.name}
          secondaryText={record => (record.active ? "active" : "inactive")}
          leftAvatar={record =>
            record.backgroundImage ? (
              <img
                src={record.backgroundImage}
                className={classes.leftAvatar}
                style={{
                  backgroundColor: record.backgroundColor
                }}
              />
            ) : (
              false
            )
          }
          tertiaryText={record =>
            record.availability.premium && <PremiumIcon />
          }
        />
      }
      medium={
        <Datagrid>
          {/* <TextField source="_id" /> */}
          <NumberField source="sortOrder" />
          <ImageField
            source="backgroundImageFile.src"
            classes={{
              image: classes.backgroundImage
            }}
            label="Background"
          />
          <BooleanField source="active" />
          <TextField source="name" cellClassName={classes.name} />
          <DateField source="created" cellClassName={classes.publishedAt} />
          <PremiumField source="availability.premium" label="Premium" />
          <ThemeListActionToolbar>
            <EditButton />
          </ThemeListActionToolbar>
        </Datagrid>
      }
    />
  </List>
));

export default ThemeList;
