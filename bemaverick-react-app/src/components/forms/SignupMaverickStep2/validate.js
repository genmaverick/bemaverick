import validateDate from "../validateDate";
import { calculateAge } from "../../../utils";

const validate = values => {
  const errors = {};
  const requiredFields = ["username", "password", "birthdate", "accept"];
  requiredFields.forEach(field => {
    if (!values[field]) {
      switch (field) {
        case "accept":
          errors[field] = "you must accept the Terms of Service to signup";
          break;
        default:
          errors[field] = `${field} is required`;
          break;
      }
    }
  });

  // Username
  if (values.username) {
    if (values.username.length < 6) {
      errors.username = "must be at lest 6 characters";
    }
    if (values.username.length > 16) {
      errors.username = "must be less than 16 characters";
    }
  }

  // Password
  if (values.password) {
    if (values.password.length < 6) {
      errors.password = "must be at lest 6 characters";
    }
    if (values.password.length > 16) {
      errors.password = "must be less than 16 characters";
    }
  }

  if (values.birthdate) {
    if (!validateDate(values.birthdate)) {
      errors.birthdate = "invalid date, try mm/dd/yyyy";
    }
  }

  // Determine age and require parent email for under 13
  if (values.birthdate) {
    const age = calculateAge(values.birthdate);
    if (age < 0) {
      errors.birthdate = "you must be born in the past";
    } else if (age < 13) {
      if (!values.parentEmailAddress) {
        errors.parentEmailAddress = "Required";
      }
    } else if (!values.emailAddress) {
      errors.emailAddress = "Required";
    }
  }

  // Email format
  if (
    values.emailAddress &&
    !/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.test(values.emailAddress)
  ) {
    errors.emailAddress = "Invalid email address";
  }
  if (
    values.parentEmailAddress &&
    !/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.test(values.parentEmailAddress)
  ) {
    errors.parentEmailAddress = "Invalid email address";
  }

  return errors;
};

export default validate;
