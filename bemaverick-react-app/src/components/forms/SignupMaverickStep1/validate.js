const validate = (values) => {
  const errors = {};
  const requiredFields = ['username', 'password', 'accept'];
  requiredFields.forEach((field) => {
    if (!values[field]) {
      switch (field) {
        case 'accept':
          errors[field] = 'you must accept the Terms of Service to signup';
          break;
        default:
          errors[field] = `${field} is required`;
          break;
      }
    }
  });
  //   if (values.email && !/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.test(values.email)) {
  //     errors.email = 'Invalid email address';
  //   }

  if (values.username) {
    if (values.username.length < 6) {
      errors.username = 'must be at lest 6 characters';
    }
    if (values.username.length > 16) {
      errors.username = 'must be less than 16 characters';
    }
  }

  if (values.password) {
    if (values.password.length < 6) {
      errors.password = 'must be at lest 6 characters';
    }
    if (values.password.length > 16) {
      errors.password = 'must be less than 16 characters';
    }
  }

  return errors;
};

export default validate;
