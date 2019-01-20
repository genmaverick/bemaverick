import React from "react";
import { translate } from "react-admin";

export default translate(({ record, translate }) => (
  <span>{record ? `Comment at ${record.parentType}_${record.parentId}` : ""}</span>
  // <span>
  //   {record ? translate("comment.edit.body", { body: record.body }) : ""}
  // </span>
));
