/* eslint-disable no-case-declarations */
module.exports = (date, format = 'maverick-api') => {
  switch (format) {
    case 'maverick-api':
    default:
      const d = new Date(date);
      let month = `${d.getMonth() + 1}`;
      let day = `${d.getDate()}`;
      const year = d.getFullYear();

      if (month.length < 2) month = `0${month}`;
      if (day.length < 2) day = `0${day}`;

      return [year, month, day].join('-');
  }
};
