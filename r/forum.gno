// examples/gno.land/p/forum/forum.gno
package forum

import (
	"std"

	"gno.land/p/demo/avl"
)

// Forum represents a single forum instance
type Forum struct {
	name string

	posts      avl.Tree // post id -> post
	categories avl.Tree // category name -> []post (for lookups)

	admin      std.Address
	moderators avl.Tree // category name -> []address
}

// NewForum creates a new forum instance
func NewForum(
	name string,
	categories []string,
	admin std.Address,
) *Forum {
	// Create a new forum instance
	f := &Forum{
		name:       name,
		categories: avl.Tree{},
		posts:      avl.Tree{},
		admin:      admin,
		moderators: avl.Tree{},
	}

	// Instantiate the categories
	for _, category := range categories {
		f.categories.Set(category, make([]*Post, 0))

		// Instantiate the initial moderator set
		f.moderators.Set(category, []std.Address{admin})
	}

	return f
}

// GetName returns the forum name
func (f Forum) GetName() string {
	return f.name
}

// GetCategories fetches the forum categories
func (f Forum) GetCategories() []string {
	var (
		categories = make([]string, f.categories.Size())
		index      = 0
	)

	f.categories.Iterate("", "", func(category *avl.Node) bool {
		// Add the category to the list
		categories[index] = category.Key()

		index++

		// Continue iteration
		return false
	})

	return categories
}

// GetComments fetches the comments for a specific post
func (f Forum) GetComments(postID uint) []*Comment {
	postRaw, found := f.posts.Get(ufmt.Sprintf("%d", postID))
	if !found {
		// Post does not exist
		return nil
	}

	post, _ := postRaw.(*Post)

	return post.GetComments()
}

// GetCategoryPosts fetches the posts associated with a specific category
func (f Forum) GetCategoryPosts(category string) []*Post {
	categoryPostsRaw, found := f.categories.Get(category)
	if !found {
		// No posts found for this category
		return nil
	}

	return categoryPostsRaw.([]*Post)
}

// GetPosts returns all posts on the forum
func (f Forum) GetPosts() []*Post {
	posts := make([]*Post, f.posts.Size())

	index := 0
	f.posts.Iterate("", "", func(n *avl.Node) bool {
		posts[index] = n.Value().(*Post)

		return false
	})

	return posts
}

// GetPost returns a post using the ID, if any
func (f Forum) GetPost(postID string) *Post {
	post, found := f.posts.Get(postID)
	if !found {
		return nil
	}

	return post.(*Post)
}
