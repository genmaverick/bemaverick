import React from "react";
import { translate } from "react-admin";

export default translate(({ record, translate }) => (
  <span>
    {record ? translate("theme.edit.name", { name: record.name }) : ""}
  </span>
));
