# frozen_string_literal: true

When(/^получаю информацию о пользователях$/) do
  users_full_information = $rest_wrap.get('/users')

  $logger.info('Информация о пользователях получена')
  @scenario_data.users_full_info = users_full_information
end

When(/^(позитивно|негативно) получаю информацию о пользователe с айди (\d+):$/) do |type, id|
  if type == 'позитивно'
    $logger.info("Негативно запрашиваем информацию о пользователе с айди: #{id}")
    user_full_information = $rest_wrap.get("/users/#{id}")

    $logger.info('Информация о пользователe получена')
    @scenario_data.user_full_info = user_full_information
  else
    $logger.info("Позитивно запрашиваем информацию о пользователе с айди: #{id}")
    users = @scenario_data.users_full_info

    max_id = users.map { |user| user['id'].to_i }.max || 0
    non_existing_id = max_id + 1
    begin
      response = $rest_wrap.get("/users/#{non_existing_id}")
      expect(response.code).to eq(404)
    rescue => e
      $logger.info("Ожидаемая ошибка при запросе несуществующего пользователя: #{e.message}")
    end
  end
end

When(/^проверяю (наличие|отсутствие) логина (\w+\.\w+) в списке пользователей$/) do |presence, login|
  if presence == 'наличие'
    search_login_in_list = true
    $logger.info("Позитивно проверяю наличие логина #{login} в списке пользователей")
  else
    search_login_in_list = false
    $logger.info("Негативно проверяю отсутствие логина #{login} в списке пользователей")
  end

  logins_from_site = @scenario_data.users_full_info.map { |f| f.try(:[], 'login') }
  login_presents = logins_from_site.include?(login)
  $logger.info("Логины из списка пользователей: #{logins_from_site.inspect}")
  if login_presents
    message = "Логин #{login} присутствует в списке пользователей"
    search_login_in_list ? $logger.info(message) : raise(message)
  else
    message = "Логин #{login} отсутствует в списке пользователей"
    search_login_in_list ? raise(message) : $logger.info(message)
  end
end

When(/^добавляю пользователя c логином (\w+\.\w+) именем (\w+) фамилией (\w+) паролем ([\d\w@!#]+)$/) do
|login, name, surname, password|
  response = $rest_wrap.post_error('/users', login: login,
                                       name: name,
                                       surname: surname,
                                       password: password,
                                       active: 1)
  @scenario_data.response = response
  $logger.info("Полученный объект запроса на добавление пользователя - #{response.inspect}")
end

When(/^(позитивно|негативно) добавляю пользователя с параметрами:$/) do |type, data_table|
  user_data = data_table.raw

  login = user_data[0][1]
  name = user_data[1][1]
  surname = user_data[2][1]
  password = user_data[3][1]

  step "добавляю пользователя c логином #{login} именем #{name} фамилией #{surname} паролем #{password}"
  if type == 'позитивно'
    $logger.info("Позитивно добавляю пользователя с логином #{login}, именем #{name}, фамилией #{surname} и паролем #{password}")
    expect(@scenario_data.response['status']).to eq(200)
  else
    $logger.info("Негативно добавляю пользователя с логином #{login}, именем #{name}, фамилией #{surname} и паролем #{password}")
    expect(@scenario_data.response.code).to eq(400)
  end
end

When(/^нахожу пользователя с логином (\w+\.\w+)$/) do |login|
  step %(получаю информацию о пользователях)
  if @scenario_data.users_id[login].nil?
    user_id = find_user_id(users_information: @scenario_data.users_full_info, user_login: login)
    if user_id.nil?
      @scenario_data.users_id[login] = nil
      $logger.error("Не удалось найти пользователя с логином #{login} в списке пользователей")
      raise "Не удалось найти пользователя с логином #{login} в списке пользователей"
    else
      @scenario_data.users_id[login] = user_id
    end
  end
  $logger.info("Найден пользователь #{login} с id:#{@scenario_data.users_id[login]}")
end

When(/^(позитивно|негативно) удаляю пользователя с логином (\w+\.\w+)$/) do |type, login|
  begin
    step %(нахожу пользователя с логином #{login})
  rescue => e
    $logger.error("Не удалось найти пользователя с логином #{login} для удаления: #{e.message}")
  end
  deleting_user_id = @scenario_data.users_id[login]
  if type == 'негативно'
    $logger.info("Негативно удаляю пользователя с логином #{login}")
    users = $rest_wrap.get('/users')
    max_id = users.map { |user| user['id'].to_i }.max || 0
    non_existing_id = max_id + 1
    begin
      response = $rest_wrap.delete("/users/#{non_existing_id}")
      expect(response.code).to eq(404)
    rescue => e
      $logger.info("Ожидаемая ошибка при удалении несуществующего пользователя: #{e.message}")
    end
  else
    $logger.info("Позитивно удаляю пользователя с логином #{login}")
    expect(deleting_user_id).not_to be_nil
    response = $rest_wrap.delete("/users/#{deleting_user_id}")
    if response['status'] == 200
      $logger.info("Пользователь с логином #{login} успешно удален")
    else
      $logger.error("Не удалось удалить пользователя с логином #{login}, код ответа: #{response.code}")
      raise "Не удалось удалить пользователя с логином #{login}, код ответа: #{response.code}"
    end
  end
end

When(/^проверяю соответствие данных пользователя эталону:$/) do |data_table|
  user_data = data_table.raw

  login = user_data[0][1]
  name = user_data[1][1]
  surname = user_data[2][1]
  active = user_data[3][1].to_i

  @scenario_data.users_full_info.select do |user|
    if user['login'] == login
      $logger.info("Проверка пользователя с логином #{login} на соответствие эталону")
      $logger.info("Логин совпадает с #{login}")
      expect(user['name']).to eq(name)
      $logger.info("Имя совпадает с #{name}")
      expect(user['surname']).to eq(surname)
      $logger.info("Фамилия совпадает с #{surname}")
      expect(user['active']).to eq(active.to_i)
      $logger.info("Активность совпадает с #{active.to_i}")
    end
  end
end

When(/^(позитивно|негативно|без_аргументов) меняю параметры пользователя с логином (\w+\.\w+):$/) do |type, login_old, data_table|
  user_data = data_table.raw

  login = user_data[0][1]
  name = user_data[1][1]
  surname = user_data[2][1]
  password = user_data[3][1]
  active = user_data[4][1].to_i
  if type == 'позитивно'
    $logger.info("Позитивно меняю пользователя с логином #{login_old} на пользователя c логином #{login} именем #{name} фамилией #{surname} паролем #{password} и активностью #{active}")
    step %(нахожу пользователя с логином #{login_old})
    changing_user_id = @scenario_data.users_id[login_old]
    response = $rest_wrap.put("/users/#{changing_user_id}", login: login,
                                        name: name,
                                        surname: surname,
                                        password: password,
                                        active: active)
    $logger.info(response.inspect)
    if response['status'] == 200
      $logger.info("Пользователь с логином #{login_old} успешно изменен")
    else
      $logger.error("Не удалось изменить пользователя с логином #{login_old}, код ответа: #{response['status']}")
      raise "Не удалось изменить пользователя с логином #{login_old}, код ответа: #{response['status']}"
    end
  elsif type == 'негативно'
    users = @scenario_data.users_full_info

    max_id = users.map { |user| user['id'].to_i }.max || 0
    non_existing_id = max_id + 1
    $logger.info("Негативно меняю пользователя с несуществующим айди #{non_existing_id}")
    begin
      response = $rest_wrap.put("/users/#{non_existing_id}", login: 'login',
                                          name: 'name',
                                          surname: 'surname',
                                          password: 'password',
                                          active: 2)
      expect(response.code).to eq(404)
    rescue => e
      $logger.info("Ожидаемая ошибка при изменении несуществующего пользователя: #{e.message}")
    end
  else
    $logger.info("Без аргументов меняю пользователя с логином #{login_old} на пользователя c логином #{login} именем #{name} фамилией #{surname} паролем #{password} и активностью #{active}")
    step %(нахожу пользователя с логином #{login_old})
    changing_user_id = @scenario_data.users_id[login_old]

    begin
      response = $rest_wrap.put("/users/#{changing_user_id}", login: login,
                                        name: name,
                                        surname: surname,
                                        password: password,
                                        active: active)
      expect(response.code).to eq(400)
    rescue => e
      $logger.info("Ожидаемая ошибка при попытке обновить данные пользователя на нил: #{e.message}")
    end
  end
end
