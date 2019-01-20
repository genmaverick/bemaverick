// in myRestProvider.js
import { stringify } from "query-string";
import {
  GET_LIST,
  GET_ONE,
  CREATE,
  UPDATE,
  DELETE,
  GET_MANY,
  GET_MANY_REFERENCE
} from "react-admin";
import config from "config";

import addUploadFeature from "./addUploadFeature";

const { lambdaApiUrl } = config;

/**
 * Maps react-admin queries to my REST API
 *
 * @param {string} type Request type, e.g GET_LIST
 * @param {string} resource Resource name, e.g. "posts"
 * @param {Object} payload Request parameters. Depends on the request type
 * @returns {Promise} the Promise for a data response
 */
const dataProvider = (type, resource, params) => {
  let url = "";
  let query = {};
  const options = {
    headers: new Headers({
      Accept: "application/json"
    })
  };
  switch (type) {
    case GET_LIST: {
      console.log('DEFAULT PROVIDER!!');
      const { page, perPage } = params.pagination;
      const { field, order } = params.sort;
      query = params.filter;
      if (!field == "id") {
        query.sort = order === "ASC" ? field : `-${field}`;
      }
      query.skip = (page - 1) * perPage;
      query.limit = perPage;
      url = `${lambdaApiUrl}/${resource}?${stringify(query)}`;
      break;
    }
    case GET_ONE:
      url = `${lambdaApiUrl}/${resource}/${params.id}`;
      break;
    case CREATE:
      url = `${lambdaApiUrl}/${resource}`;
      options.method = "POST";
      options.body = JSON.stringify(params.data);
      break;
    case UPDATE:
      url = `${lambdaApiUrl}/${resource}/${params.id}`;
      options.method = "PUT";
      options.body = JSON.stringify(params.data);
      break;
    case UPDATE_MANY:
      query = {
        filter: JSON.stringify({ id: params.ids })
      };
      url = `${lambdaApiUrl}/${resource}?${stringify(query)}`;
      options.method = "PATCH";
      options.body = JSON.stringify(params.data);
      break;
    case DELETE:
      url = `${lambdaApiUrl}/${resource}/${params.id}`;
      options.method = "DELETE";
      break;
    case DELETE_MANY:
      query = {
        filter: JSON.stringify({ id: params.ids })
      };
      url = `${lambdaApiUrl}/${resource}?${stringify(query)}`;
      options.method = "DELETE";
      break;
    case GET_MANY: {
      query = {
        filter: JSON.stringify({ id: params.ids })
      };
      url = `${lambdaApiUrl}/${resource}?${stringify(query)}`;
      break;
    }
    case GET_MANY_REFERENCE: {
      const { page, perPage } = params.pagination;
      const { field, order } = params.sort;
      query = {
        sort: JSON.stringify([field, order]),
        range: JSON.stringify([(page - 1) * perPage, page * perPage - 1]),
        filter: JSON.stringify({
          ...params.filter,
          [params.target]: params.id
        })
      };
      url = `${lambdaApiUrl}/${resource}?${stringify(query)}`;
      break;
    }
    default:
      throw new Error(`Unsupported Data Provider request type ${type}`);
  }

  // console.log("fetch(url)", url);
  return fetch(url, options)
    .then(res => res.json())
    .then(response => {
      // console.log("response", response);
      /* Convert HTTP Response to Data Provider Response */
      /* https://marmelab.com/react-admin/DataProviders.html#writing-your-own-data-provider */
      let dataResponse = {};

      switch (type) {
        case GET_LIST:
          dataResponse = {
            data: response.data.map(row => {
              return { id: row._id, ...row };
            }),
            total: response.meta.count
          };
          break;
        default:
          dataResponse = {
            data: { id: response._id, ...response }
          };
      }
      // console.log("dataResponse", dataResponse);
      return dataResponse;
    });
};

const uploadCapableDataProvider = addUploadFeature(dataProvider);

export default uploadCapableDataProvider;
