import RichTextInput from "ra-input-rich-text";
import React from "react";
import {
  ArrayInput,
  AutocompleteInput,
  BooleanInput,
  CheckboxGroupInput,
  Datagrid,
  DateField,
  DateInput,
  DisabledInput,
  Edit,
  EditButton,
  FileInput,
  FormTab,
  ImageField,
  ImageInput,
  LongTextInput,
  NumberInput,
  ReferenceArrayInput,
  ReferenceInput,
  ReferenceManyField,
  SelectArrayInput,
  SelectInput,
  SimpleForm,
  SimpleFormIterator,
  TabbedForm,
  TextField,
  TextInput,
  minValue,
  maxValue,
  number,
  required
} from "react-admin"; // eslint-disable-line import/no-unresolved
import Divider from "components/Divider";
import { ColorInput } from "react-admin-color-input";
import Subheading from "components/Subheading";
import Title from "components/Title";
import S3Input from "components/S3Input";
import ThemeTitle from "./ThemeTitle";
import * as options from "./options";

const ThemeEdit = props => (
  <Edit title={<ThemeTitle />} {...props}>
    <TabbedForm>
      <FormTab label="Name & Background">
        <TextInput source="name" validate={required()} />
        <ImageInput
          source="backgroundImageFile"
          label="Background Image"
          accept="image/*"
          placeholder={<p>Drop your image here</p>}
          multiple={false}
        >
          <ImageField source="src" title="title" />
        </ImageInput>
        <ColorInput source="backgroundColor" picker="Sketch" />
        <BooleanInput
          label="Allow Background Transparency"
          source="allowAlpha"
          defaultValue={false}
        />
      </FormTab>

      <FormTab label="Font">
        <SelectInput source="fontName" choices={options.fontName} />
        <NumberInput
          source="maxFontSize"
          step={1}
          defaultValue={38}
          validate={number() && minValue(1)}
        />
        <NumberInput
          source="maxCharacters"
          step={1}
          defaultValue={0}
          validate={number() && minValue(0)}
        />
        <ColorInput source="fontColor" picker="Sketch" />
        <SelectInput source="textTransform" choices={options.textTransform} />
        <SelectInput
          source="justification"
          choices={options.justification}
          validate={required()}
          defaultValue="center"
        />
        <BooleanInput
          label="Has Text Shadow"
          source="hasShadow"
          defaultValue={false}
        />
      </FormTab>

      <FormTab label="Padding">
        <NumberInput
          source="paddingTop"
          step={1}
          defaultValue={12}
          validate={number() && minValue(0) && maxValue(100)}
        />
        <NumberInput
          source="paddingRight"
          step={1}
          defaultValue={12}
          validate={number() && minValue(0) && maxValue(100)}
        />
        <NumberInput
          source="paddingBottom"
          step={1}
          defaultValue={12}
          validate={number() && minValue(0) && maxValue(100)}
        />
        <NumberInput
          source="paddingLeft"
          step={1}
          defaultValue={12}
          validate={number() && minValue(0) && maxValue(100)}
        />
      </FormTab>

      <FormTab label="Premium">
        <ReferenceInput source="reward" reference="rewards" label="Reward Pack">
          <SelectInput/>
        </ReferenceInput>
      </FormTab>
      <FormTab label="Other">
        <BooleanInput source="active" />
        <DisabledInput source="id" />
        <NumberInput source="sortOrder" />
      </FormTab>
    </TabbedForm>
  </Edit>
);

export default ThemeEdit;
