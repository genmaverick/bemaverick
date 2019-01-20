const convertToChoices = choices => {
  return choices.map(choice => {
    return { id: choice, name: choice };
  });
};

export const textTransform = [
  { id: "none", name: "None" },
  { id: "lowercase", name: "Lowercase" },
  { id: "uppercase", name: "Uppercase" }
];

export const fontName = convertToChoices([
  "BarlowItalic",
  "BarlowSemiboldItalic",
  "BarlowBlackItalic",
  "OpensansItalic",
  "OpenSansSemiboldItalic"
]);
