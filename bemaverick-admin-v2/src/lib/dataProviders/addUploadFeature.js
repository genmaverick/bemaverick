const convertFileToBase64 = file =>
  new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file.rawFile);

    reader.onload = () => resolve(reader.result);
    reader.onerror = reject;
  });

const addUploadCapabilities = requestHandler => (type, resource, params) => {
  if (["UPDATE", "CREATE"].includes(type) && resource === "themes") {
    if (
      params.data.backgroundImageFile &&
      params.data.backgroundImageFile.rawFile
    ) {
      // only freshly dropped pictures are instance of File
      const { backgroundImageFile } = params.data;
      if (backgroundImageFile.rawFile instanceof File) {
        return convertFileToBase64(backgroundImageFile)
          .then(base64File => ({
            src: base64File,
            title: `${backgroundImageFile.title}`
          }))
          .then(transformedFile =>
            requestHandler(type, resource, {
              ...params,
              data: {
                ...params.data,
                uploadBackgroundImageFile: transformedFile
              }
            })
          )
          .catch(error => {
            console.log("convertFileToBase64.error", error);
            requestHandler(type, resource, params);
          });
      }
    }
  }

  return requestHandler(type, resource, params);
};

export default addUploadCapabilities;
