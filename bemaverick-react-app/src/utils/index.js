/* eslint-disable import/prefer-default-export */
export const calculateAge = (birthdate) => {
  const convertedBirthdate = new Date(birthdate);

  if (convertedBirthdate === null || typeof convertedBirthdate.getMonth !== 'function') {
    return null;
  }
  
  // birthday is a date
  const ageDifMs = Date.now() - convertedBirthdate.getTime();
  const ageDate = new Date(ageDifMs); // miliseconds from epoch
  return ageDate.getUTCFullYear() - 1970;
};
