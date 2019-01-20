import { createMuiTheme } from "@material-ui/core/styles";

const theme = createMuiTheme({
  palette: {
    primary: {
      light: "#5adae2",
      main: "#00a8b0",
      dark: "#007881",
      contrastText: "#ffffff"
    },
    secondary: {
      light: "#f359f3",
      main: "#bd15c0",
      dark: "#89008f",
      contrastText: "#ffffff"
    }
  }
});

export default theme;
