import '../model/Store.dart';
import '../redux/actions.dart';

Store storeReducer(Store items, dynamic action) {
  if (action is SetUser) {
    return setUser(items, action);
  } else {
    return items;
  }
}

Store setUser(Store store, SetUser action) {
  store.user = action.user;
  return store;
}
