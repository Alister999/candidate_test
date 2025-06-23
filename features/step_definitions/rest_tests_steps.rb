# frozen_string_literal: true

When(/^получаю информацию о пользователях$/) do
  users_full_information = $rest_wrap.get('/users')

  $logger.info('Информация о пользователях получена')
  @scenario_data.users_full_info = users_full_information
end

When(/^проверяю (наличие|отсутствие) логина (\w+\.\w+) в списке пользователей$/) do |presence, login|
  search_login_in_list = true
  presence == 'отсутствие' ? search_login_in_list = !search_login_in_list : search_login_in_list

  logins_from_site = @scenario_data.users_full_info.map { |f| f.try(:[], 'login') }
  login_presents = logins_from_site.include?(login)

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

  response = $rest_wrap.post('/users', login: login,
                                       name: name,
                                       surname: surname,
                                       password: password,
                                       active: 1)
  $logger.info(response.inspect)
end

When(/^добавляю пользователя с параметрами:$/) do |data_table|
  user_data = data_table.raw

  login = user_data[0][1]
  name = user_data[1][1]
  surname = user_data[2][1]
  password = user_data[3][1]

  step "добавляю пользователя c логином #{login} именем #{name} фамилией #{surname} паролем #{password}"
end

When(/^нахожу пользователя с логином (\w+\.\w+)$/) do |login|
  step %(получаю информацию о пользователях)
  if @scenario_data.users_id[login].nil?
    @scenario_data.users_id[login] = find_user_id(users_information: @scenario_data
                                                                         .users_full_info,
                                                  user_login: login)
  end

  $logger.info("Найден пользователь #{login} с id:#{@scenario_data.users_id[login]}")
end


When(/^удаляю пользователя с логином (\w+\.\w+)$/) do |login|
  step %(нахожу пользователя с логином #{login})
  deleting_user_id = @scenario_data.users_id[login]

  response = $rest_wrap.delete("/users/#{deleting_user_id}")
  if response['status'] == 200
    $logger.info("Пользователь с логином #{login} успешно удален")
  else
    raise "Не удалось удалить пользователя с логином #{login}, код ответа: #{response.code}"
  end
end

When(/^Проверяю соответствие данных пользователя с логином (\w+\.\w+) эталону:$/) do |login_old, data_table|
  user_data = data_table.raw

  login = user_data[0][1]
  name = user_data[1][1]
  surname = user_data[2][1]
  password = user_data[3][1]
  active = user_data[4][1].to_i

  @scenario_data.users_full_info.select do |user|
    if user['login'] == login
      $logger.info("Проверка пользователя с логином #{login} на соответствие эталону")
      expect(user['name']).to eq(name)
      expect(user['surname']).to eq(surname)
      expect(user['active']).to eq(active.to_i)
    end
  end
end

When(/^меняю параметры пользователя с логином (\w+\.\w+):$/) do |login_old, data_table|
  user_data = data_table.raw

  login = user_data[0][1]
  name = user_data[1][1]
  surname = user_data[2][1]
  password = user_data[3][1]
  active = user_data[4][1].to_i

  $logger.info("меняю пользователя с логином #{login_old} на пользователя c логином #{login} именем #{name} фамилией #{surname} паролем #{password} и активностью #{active}")
  
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
    raise "Не удалось изменить пользователя с логином #{login_old}, код ответа: #{response['status']}"
  end
end
