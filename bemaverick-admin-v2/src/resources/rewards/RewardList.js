import get from "lodash/get";
import Chip from "@material-ui/core/Chip";
import { withStyles } from "@material-ui/core/styles";
import React, { Children, cloneElement } from "react";
import {
  Datagrid,
  DateField,
  EditButton,
  Filter,
  List,
  Responsive,
  SimpleList,
  TextField,
  TextInput,
  ImageField,
  NullableBooleanInput,
} from "react-admin"; // eslint-disable-line import/no-unresolved
import ActiveField from "./ActiveField";

const QuickFilter = ({ label }) => (
  <Chip style={{ marginBottom: 8 }} label={label} />
);

const CommentFilter = props => (
    <Filter {...props}>
      <NullableBooleanInput source="active" label="Active?" />
      <NullableBooleanInput source="flagged" label="Flagged?" />
      <TextInput source="meta.user.username" label="Search by username" /> 
     {/* <ReferenceInput source="userId" reference="comments">
        <AutocompleteInput
            optionText={choice =>
                `${choice.meta.user.username}`
            }
        />
      </ReferenceInput> */}
      {/* <ReferenceInput label="Username" source="userId" reference="comments" >
        <AutocompleteInput
            optionText={choice =>
              `${choice.meta.user.username}`
            }
        />
      </ReferenceInput> */}
    </Filter>
);

const styles = theme => ({
  status: { width: 150 },
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
  profileImage: {
    height: "50px",
    width: "50px",
    borderRadius: "50%",
  },
});

const CommentListActionToolbar = withStyles({
  toolbar: {
    alignItems: "center",
    display: "flex"
  }
})(({ classes, children, ...props }) => (
  <div className={classes.toolbar}>
    {Children.map(children, button => cloneElement(button, props))}
  </div>
));

const CommentList = withStyles(styles)(({ classes, ...props }) => (
  <List
    {...props}
    perPage={25}
    filters={<CommentFilter />}
    bulkActions={false}
    filterDefaultValues={{ active:'true,false'}}
  >
    <Responsive
      small={
        <SimpleList
          key={record => {
            return record._id;
          }}
          primaryText={record => record.name}
          // secondaryText={record => record.meta.user.username}
          // leftAvatar={record =>
          //   get(record, "meta.user.profileImage.url") ? (
          //     <img
          //       src={record.meta.user.profileImage.url}
          //       className={classes.profileImage}
          //       style={{
          //         backgroundColor: record.backgroundColor
          //       }}
          //     />
          //   ) : (
          //     false
          //   )
          // }
        />
      }
      medium={
        <Datagrid>
          {/* <ImageField
            source="meta.user.profileImage.url"
            classes={{
              image: classes.profileImage
            }}
            label="Avatar"
          /> */}
          <TextField source="name" cellClassName={classes.name} label="Reward Name" />
          {/* <TextField source="body" cellClassName={classes.name} label="Comment" />
          <DateField source="created" cellClassName={classes.publishedAt} label="Published"/> */}
          <ActiveField source="active" label="Active" />
          {/* <CommentListActionToolbar>
            <EditButton />
          </CommentListActionToolbar> */}
        </Datagrid>
      }
    />
  </List>
));

export default CommentList;
