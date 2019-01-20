import RichTextInput from "ra-input-rich-text";
import { withStyles } from "@material-ui/core/styles";
import React from "react";
import {
  Edit,
  FormTab,
  ImageField,
  TabbedForm,
  TextField,
} from "react-admin"; // eslint-disable-line import/no-unresolved
import RewardTitle from "./RewardTitle";
import * as options from "./options";
import LocationLink from "components/LocationLink";

const styles = theme => ({
  profileImage: {
    height: "200px",
    width: "auto",
  },
});

const CommentEdit = withStyles(styles)(({ classes, ...props }) => (
  <Edit title={<CommentTitle />} {...props}>
    <TabbedForm>
      <FormTab label="Comment">
        <TextField source="body" label="Comment after Moderation" />
        <TextField source="originalBody" label="Comment before Moderation" />
        <TextField source="parentType" label="Parent Type" />
        <TextField source="parentId" label="Parent Id" />
        <LocationLink contentType="content" />
      </FormTab>
      <FormTab label="User">
        <TextField source="meta.user.username" label="Username" />
        <TextField source="meta.user.userId" label="UserId" />
        <ImageField
            source="meta.user.profileImage.url"
            classes={{
              image: classes.profileImage
            }}
            label="Avatar"
          />
          <LocationLink contentType="user" />
      </FormTab> 
    </TabbedForm>
  </Edit>
)
);

export default CommentEdit;
