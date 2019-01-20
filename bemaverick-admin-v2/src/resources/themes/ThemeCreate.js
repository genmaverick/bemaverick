import RichTextInput from "ra-input-rich-text";
import React from "react";
import {
  ArrayInput,
  BooleanInput,
  CheckboxGroupInput,
  Create,
  Datagrid,
  DateField,
  DateInput,
  DisabledInput,
  Edit,
  EditButton,
  FormTab,
  ImageField,
  ImageInput,
  LongTextInput,
  maxValue,
  minValue,
  NumberInput,
  ReferenceArrayInput,
  ReferenceManyField,
  SelectArrayInput,
  SelectInput,
  SimpleForm,
  SimpleFormIterator,
  TabbedForm,
  TextField,
  TextInput,
  number,
  required
} from "react-admin"; // eslint-disable-line import/no-unresolved
import Divider from "components/Divider";
import { ColorInput } from "react-admin-color-input";
import Subheading from "components/Subheading";
import Title from "components/Title";
import ThemeTitle from "./ThemeTitle";
import * as options from "./options";

const ThemeCreate = props => (
  <Create title={"Create a New Theme"} {...props}>
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
        <ColorInput
          source="backgroundColor"
          picker="Sketch"
          defaultValue={"#ffffff"}
        />
        <BooleanInput
          label="Allow Background Transparency"
          source="allowAlpha"
          defaultValue={true}
        />
      </FormTab>

      <FormTab label="Font">
        <SelectInput
          source="fontName"
          choices={options.fontName}
          validate={required()}
          defaultValue="PTSansRegular"
        />
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
        <ColorInput
          source="fontColor"
          picker="Sketch"
          validate={required()}
          defaultValue={"#000000"}
        />
        <SelectInput
          source="textTransform"
          choices={options.textTransform}
          defaultValue={"none"}
        />
        <SelectInput
          source="justification"
          choices={options.justification}
          validate={required()}
          defaultValue="center"
        />
        <BooleanInput
          label="has Text Shadow"
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
        <BooleanInput label="Premium Theme" source="availability.premium" />
        <NumberInput
          label="Minimum Posts"
          source="availability.minPosts"
          step={1}
          defaultValue={0}
          validate={number()}
        />
        <NumberInput
          label="Minimum Badges"
          source="availability.minBadges"
          step={1}
          defaultValue={0}
          validate={number()}
        />
      </FormTab>

      <FormTab label="Other">
        <BooleanInput source="active" />
        <NumberInput source="sortOrder" defaultValue={0} />
      </FormTab>
    </TabbedForm>
  </Create>
);

export default ThemeCreate;
