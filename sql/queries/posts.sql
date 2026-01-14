-- name: CreatePost :exec
INSERT INTO posts (
    id, created_at, updated_at, title, url, description, published_at, feed_id
)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8);

-- name: GetPostsForUser :many
SELECT 
    posts.id,
    posts.title,
    posts.url,
    posts.description,
    posts.published_at,
    posts.feed_id
FROM posts
JOIN feed_follows ON posts.feed_id = feed_follows.feed_id
WHERE feed_follows.user_id = $1
ORDER BY posts.published_at DESC
LIMIT $2;
