CREATE TABLE
    Topics (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        questions_type VARCHAR(20) CHECK (questions_type IN ('short', 'long'))
    );

CREATE TABLE
    Variants (id SERIAL PRIMARY KEY, name VARCHAR(255) NOT NULL);

CREATE TABLE
    Questions (
        id SERIAL PRIMARY KEY,
        text TEXT NOT NULL,
        body TEXT,
        image VARCHAR(255),
        correct_answer VARCHAR(255), -- Nullable for long answer questions
        answer_type VARCHAR(20) CHECK (answer_type IN ('short', 'long')),
        topic_id INT,
        FOREIGN KEY (topic_id) REFERENCES Topics (id)
    );

CREATE TABLE
    Questions_Variants (
        id SERIAL PRIMARY KEY,
        question_id INT,
        variant_id INT,
        FOREIGN KEY (question_id) REFERENCES Questions (id),
        FOREIGN KEY (variant_id) REFERENCES Variants (id),
        UNIQUE (question_id, variant_id)
    );

-- CREATE OR REPLACE FUNCTION validate_question_type()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     IF EXISTS (
--         SELECT 1 
--         FROM Topics 
--         WHERE id = NEW.topic_id 
--         AND questions_type != NEW.answer_type
--     ) THEN
--         RAISE EXCEPTION 'The questions_type of the topic does not match the answer_type of the question.';
--     END IF;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;
CREATE TRIGGER check_question_type BEFORE INSERT
OR
UPDATE ON Questions FOR EACH ROW EXECUTE FUNCTION validate_question_type ();

INSERT INTO
    Topics (name, questions_type)
VALUES
    (
        'Установление последовательности событий', -- 1
        'short'
    ),
    ('Понятия, термины', 'short'), -- 2
    (
        'Систематизация исторической информации (соответствие)', -- 3
        'short'
    ),
    ('Анализ карты, схемы', 'short'), -- 4
    (
        'История VIII–XXI веков: иллюстративный материал', -- 5
        'short'
    ),
    (
        'Информация, представленная в виде схемы', -- 6
        'short'
    ),
    (
        'Факты истории культуры древнейших времён до 1914 г', -- 7
        'short'
    ),
    ('История зарубежных стран', 'short'), -- 8
    ('Анализ источника', 'long'), -- 9
    (
        'Выявление и объяснение причин исторических событий, процессов', -- 10
        'long'
    ),
    (
        'Сравнение исторических событий и явлений', -- 11
        'long'
    ),
    ('Анализ исторической ситуации', 'long');

-- 12
INSERT INTO
    Variants (name)
VALUES
    ('Вариант 1'),
    ('Вариант 2'),
    ('Вариант 3'),
    ('Вариант 4'),
    ('Вариант 5'),
    ('Вариант 6'),
    ('Вариант 7'),
    ('Вариант 8'),
    ('Вариант 9'),
    ('Вариант 10');

INSERT INTO
    Questions (
        text,
        body,
        image,
        correct_answer,
        answer_type,
        topic_id
    )
VALUES
    (
        'Расположите в хронологическом порядке следующие события. Укажите ответ в виде последовательности цифр выбранных элементов.',
        '
        1)  поход князя Олега на Царьград
        2)  начало составления Русской Правды
        3)  установление уроков и погостов
        4)  первое упоминание Москвы в летописи',
        null,
        '1423',
        'short',
        1
    ),
    (
        'Запишите термин, о котором идет речь.',
        '
        «Введенный Петром I налог, взимаемый с каждого мужчины, принадлежавшего к податному сословию, независимо от возраста».',
        null,
        'подушная подать',
        'short',
        2
    ),
    (
        'Какие направления содержала аграрная реформа П. А. Столыпина? Найдите в приведенном ниже списке два направления и запишите цифры, под которыми они указаны.',
        '
        1)  переселение малоземельных крестьян за Урал
        2)  укрепление крестьянской общины
        3)  ограничение использования в сельском хозяйстве наемного труда
        4)  поддержка деятельности Крестьянского банка
        5)  принудительное отчуждение помещичьих земель',
        null,
        '13',
        'short',
        3
    ),
    (
        'Ниже приведен перечень терминов. Все они, за исключением одного, непосредственно связаны с периодом правления Ивана IV. Найдите и запишите порядковый номер термина, «выпадающего» из данного ряда.',
        '
        1)  Земский собор
        2)  Соборное уложение
        3)  Избранная рада
        4)  опричное войско
        5)  Стоглавый собор
        ',
        null,
        '2',
        'short',
        2
    ),
    (
        'Укажите век, когда русскими князьями были совершены походы, обозначенные на схеме. Ответ запишите словом.',
        null,
        '/1.png',
        'ответ',
        'short',
        4
    );

INSERT INTO
    Questions_Variants (variant_id, question_id)
VALUES
    (1, 1),
    (1, 2),
    (1, 3),
    (1, 4),
    (1, 5),
    (10, 1);

-- Регистрация
CREATE TABLE
    IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) NOT NULL UNIQUE,
        email VARCHAR(255) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        created_at TIMESTAMP
        WITH
            TIME ZONE DEFAULT now ()
    );

CREATE TABLE
    Attempts (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL,
        variant_id BIGINT NOT NULL,
        total_questions INTEGER NOT NULL,
        correct_questions INTEGER NOT NULL,
        successful BOOLEAN NOT NULL,
        created_at TIMESTAMP DEFAULT NOW ()
    );