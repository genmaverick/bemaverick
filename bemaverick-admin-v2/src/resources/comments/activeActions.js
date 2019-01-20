import { DELETE, UPDATE } from 'react-admin';

export const ACTIVE_TO_TRUE = 'ACTIVE_TO_TRUE';

export const activeToTrue = (id, data, basePath) => ({
    type: ACTIVE_TO_TRUE,
    payload: { id, data: { ...data, active: true }, basePath },
    meta: {
        resource: 'comments',
        fetch: UPDATE,
        onSuccess: {
            notification: {
                body: 'resources.comments.activeStatus.activate_success',
                level: 'info',
            },
            redirectTo: '/comments',
            basePath,
        },
        onFailure: {
            notification: {
                body: 'resources.comments.activeStatus.activate_error',
                level: 'warning',
            },
        },
    },
});

export const ACTIVE_TO_FALSE = 'ACTIVE_TO_FALSE';

export const activeToFalse = (id, data, basePath) => ({
    type: ACTIVE_TO_FALSE,
    payload: { id, data: { ...data, active: false }, basePath },
    meta: {
        resource: 'comments',
        fetch: DELETE,
        onSuccess: {
            notification: {
                body: 'resources.comments.activeStatus.deactivate_success',
                level: 'info',
            },
            redirectTo: '/comments',
            basePath,
        },
        onFailure: {
            notification: {
                body: 'resources.comments.activeStatus.deactivate_error',
                level: 'warning',
            },
        },
    },
});