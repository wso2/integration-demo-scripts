CREATE TABLE ripplit_db.users (
    id INT NOT NULL auto_increment PRIMARY KEY,
    birth_date DATE,
    name VARCHAR(255)
);
CREATE TABLE ripplit_db.posts (
    id INT NOT NULL auto_increment PRIMARY KEY,
    description VARCHAR(255),
    category VARCHAR(255),
    created_time_stamp TIMESTAMP,
    tags VARCHAR(255),
    user_id INT
);
ALTER TABLE ripplit_db.posts ADD FOREIGN KEY (user_id) REFERENCES ripplit_db.users(id) ON DELETE CASCADE;

ALTER TABLE ripplit_db.users ADD mobile_number VARCHAR(15) NOT NULL;

INSERT INTO ripplit_db.users (
        id,
        birth_date,
        name,
        mobile_number
    )
VALUES (
        1,
        CURRENT_TIMESTAMP(),
        "Wise Guy",
        "+94771234001"
    );
INSERT INTO ripplit_db.users (
        id,
        birth_date,
        name,
        mobile_number
    )
VALUES (
        2,
        CURRENT_TIMESTAMP(),
        "Musk Parody",
        "+94771234002"
    );
INSERT INTO ripplit_db.users (
        id,
        birth_date,
        name,
        mobile_number
    )
VALUES (
        3,
        CURRENT_TIMESTAMP(),
        "Seneca",
        "+94771234001"
    );
INSERT INTO ripplit_db.users (
        id,
        birth_date,
        name,
        mobile_number
    )
VALUES (
        4,
        CURRENT_TIMESTAMP(),
        "Walter White",
        "+94768787189"
    );
INSERT INTO ripplit_db.posts (
        description,
        category,
        created_time_stamp,
        tags,
        user_id
    )
VALUES (
        'Failing to prepare is preparing to fail!',
        'education',
        CURRENT_TIMESTAMP(),
        'fail,prepare,learn',
        1
    );
INSERT INTO ripplit_db.posts (
        description,
        category,
        created_time_stamp,
        tags,
        user_id
    )
VALUES (
        'Plan your work and work your plan.',
        'education',
        CURRENT_TIMESTAMP(),
        'plan,work,learn',
        1
    );
INSERT INTO ripplit_db.posts (
        description,
        category,
        created_time_stamp,
        tags,
        user_id
    )
VALUES (
        'We are going to Mars!',
        'future',
        CURRENT_TIMESTAMP(),
        'space,mars,hope',
        2
    );
INSERT INTO ripplit_db.posts (
        description,
        category,
        created_time_stamp,
        tags,
        user_id
    )
VALUES (
        'We suffer more in imagination than in reality.',
        'quotes',
        CURRENT_TIMESTAMP(),
        'suffer,reality,imagination,truth',
        3
    );
INSERT INTO ripplit_db.posts (
        description,
        category,
        created_time_stamp,
        tags,
        user_id
    )
VALUES (
        'I am still alive and cooking something special!',
        'tv',
        CURRENT_TIMESTAMP(),
        'shows,breakingbad,best',
        4
    );
CREATE TABLE ripplit_db.followers (
    id INT NOT NULL auto_increment PRIMARY KEY,
    created_time_stamp DATE,
    leader_id INT,
    follower_id INT,
    UNIQUE (leader_id, follower_id),
    FOREIGN KEY (leader_id) REFERENCES ripplit_db.users(id) ON DELETE CASCADE,
    FOREIGN KEY (follower_id) REFERENCES ripplit_db.users(id) ON DELETE CASCADE
);
INSERT INTO ripplit_db.followers (
        created_time_stamp,
        leader_id,
        follower_id
    )
VALUES (CURRENT_TIMESTAMP(), 1, 4);
