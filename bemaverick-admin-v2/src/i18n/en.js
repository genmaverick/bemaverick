import englishMessages from "ra-language-english";

export const messages = {
  simple: {
    action: {
      resetViews: "Reset views"
    }
  },
  ...englishMessages,
  resources: {
    themes: {
      name: "Theme |||| Themes",
      fields: {
        id: "ID"
      }
    },
    posts: {
      name: "Post |||| Posts",
      fields: {
        average_note: "Average note",
        body: "Body",
        comments: "Comments",
        commentable: "Commentable",
        commentable_short: "Com.",
        created_at: "Created at",
        notifications: "Notifications recipients",
        nb_view: "Nb views",
        password: "Password (if protected post)",
        pictures: "Related Pictures",
        published_at: "Published at",
        teaser: "Teaser",
        tags: "Tags",
        title: "Title",
        views: "Views"
      }
    },
    comments: {
      activeStatus: {
        activate_error: 'error reactivating comment',
        activate_success: 'comment successfully reactivated',
        deactivate_error: 'error deactivating comment',
        deactivate_success: 'comment successfully deactivated',
      },
      name: "Comment |||| Comments",
      fields: {
        body: "Body",
        created_at: "Created at",
        post_id: "Posts",
        author: {
          name: "Author"
        }
      }
    },
    rewards: {
      name: "Reward |||| Rewards",
    },
    users: {
      name: "User |||| Users",
      fields: {
        name: "Name",
        role: "Role"
      }
    }
  },
  comment: {
    list: {
      about: "About"
    }
  },
  post: {
    list: {
      search: "Search"
    },
    form: {
      summary: "Summary",
      body: "Body",
      miscellaneous: "Miscellaneous",
      comments: "Comments"
    },
    edit: {
      title: 'Post "%{title}"'
    },
    action: {
      save_and_add: "Save and Add",
      save_and_show: "Save and Show"
    }
  },
  theme: {
    create: {
      name: "Create New Theme"
    },
    edit: {
      name: '"%{name}" Theme'
    }
  },
  user: {
    list: {
      search: "Search"
    },
    form: {
      summary: "Summary",
      security: "Security"
    },
    edit: {
      title: 'User "%{title}"'
    },
    action: {
      save_and_add: "Save and Add",
      save_and_show: "Save and Show"
    }
  }
};

export default messages;
