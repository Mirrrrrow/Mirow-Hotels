
CREATE TABLE `hotels` (
  `id` int(11) NOT NULL,
  `owner` varchar(255) NOT NULL DEFAULT 'none',
  `price` int(11) NOT NULL DEFAULT 0,
  `locked` int(11) NOT NULL DEFAULT 1,
  `minibar` longtext NOT NULL,
  `position` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `hotels` (`id`, `owner`, `price`, `locked`, `minibar`, `position`) VALUES
(5, 'none', 12, 1, '[{\"amount\":2,\"label\":\"Bread\",\"cost\":3,\"name\":\"bread\"},{\"amount\":0,\"label\":\"Oil\",\"cost\":80,\"name\":\"petrol\"},{\"amount\":0,\"label\":\"Wasser\",\"cost\":1,\"name\":\"water\"}]', '{\"z\":29.3,\"y\":-1759.4,\"x\":558.0,\"heading\":0.0}'),
(8, 'none', 12, 1, '[{\"name\":\"bread\",\"label\":\"Bread\",\"amount\":2,\"cost\":3},{\"name\":\"petrol\",\"label\":\"Oil\",\"amount\":0,\"cost\":80},{\"name\":\"water\",\"label\":\"Wasser\",\"amount\":0,\"cost\":1}]', '{\"x\":561.3666,\"y\":-1751.8977,\"z\":29.2800}');

ALTER TABLE `hotels`
  ADD PRIMARY KEY (`id`);
COMMIT;

ALTER TABLE `users`
ADD COLUMN `hotelroom` int(11) NOT NULL DEFAULT 0;

ALTER TABLE `users`
ADD COLUMN `inhotelroom` int(11) NOT NULL DEFAULT 0;

    

